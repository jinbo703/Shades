//
//  ReviewVideoController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import AssetsLibrary
import Photos
import SVProgressHUD
import Firebase

class ReviewVideoController: UIViewController, MPMediaPickerControllerDelegate {
    
    @IBOutlet var viewContent:UIView!
    
    var storageRef: StorageReference = Storage.storage().reference(forURL: FIREBASE_APP_URL)
    
    var finalPath : URL?
    public var thumbnail:UIImage!
    
    var parentVC:UIViewController!
    
    var player:AVPlayer!
    let playerController = AVPlayerViewController()
    
    var notificationObserver:NSObjectProtocol!
    var watermarkVideoPath:URL!
    
    var uploadedVideoUrl:String! = nil
    var uploadedThumbnailUrl:String! = nil
    
    var songTitle = "Untitled"
    
    var userRefH:DatabaseHandle! = nil
    
    static var sharedReview:ReviewVideoController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ReviewVideoController.sharedReview = self
        
        let videoPath = UserDefaults.standard.object(forKey: "video_merged") as! String?
        let waterMarkPath = UserDefaults.standard.object(forKey: "video_watermark") as! String?
        if videoPath == nil || waterMarkPath == nil {
            self.showJHTAlerttOkayWithIcon(message:"Invalid video! Please try to capture video again!")
            self.gotoCameraView()
            return
        }
        
        let videoUrl = URL(fileURLWithPath: videoPath!)
        let waterUrl = URL(fileURLWithPath: waterMarkPath!)
        guard let audioPath = getAudioPath() else { return }
//        if audioPath.characters.count < 1 {
//            mergeFilesWithUrl_WaterMark(videoUrl: videoUrl, waterUrl: waterUrl);
//        }
//        else {
//            let fullPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(audioPath)
//            if FileManager.default.fileExists(atPath: fullPath) == false {
//                self.showJHTAlerttOkayWithIcon(message:"The song file doesn't exist! Please check the Music library!")
//                self.gotoCameraView()
//                return
//            }
//            let audioUrl = URL(fileURLWithPath: fullPath)
//            mergeFilesWithUrl_WaterMark(videoUrl: videoUrl, audioUrl: audioUrl, waterUrl: waterUrl)
//    }
        mergeFilesWithUrl_WaterMark(videoUrl: videoUrl, audioUrl: audioPath, waterUrl: waterUrl)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if player != nil {
            NotificationCenter.default.removeObserver(self.notificationObserver)
            player.pause()
            playerController.view.removeFromSuperview()
            playerController.removeFromParentViewController()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        if player != nil {
            player.play()
        }
    }
    
    @objc func reviewVideo() {
        
        player = AVPlayer(url: finalPath!)
        playerController.player = player
        playerController.view.frame = self.viewContent.bounds
        playerController.showsPlaybackControls = false
        self.addChildViewController(playerController)
        self.viewContent.addSubview(playerController.view)
        player.play()
        
        self.notificationObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { _ in
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        }
    }
    
    @IBAction func onClickedBack(_ sender: Any) {
        
        gotoCameraView()
    }
    
    func gotoCameraView() {
        
        (self.parentVC as! RecordViewController).initSession()
        (self.parentVC as! RecordViewController).initData()
        self.navigationController?.popViewController(animated: true)
        ReviewVideoController.sharedReview = nil
    }
    
    @IBAction func onClickedSave(_ sender: Any) {
        
        if self.finalPath == nil {
            return
        }
        
        SVProgressHUD.show()
        self.saveToAlbum()
    }
    
    @IBAction func onClickedPost(_ sender: Any) {
        postNewVideo()
    }
    
    func mergeFilesWithUrl(videoUrl: URL, audioUrl: URL) {
        SVProgressHUD.show()
        let mixComposition = AVMutableComposition()
        let totalVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionBackTrack : [AVMutableCompositionTrack] = []
        
        let videoAsset = AVAsset(url: videoUrl)
        let audioAsset = AVAsset(url: audioUrl)
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionBackTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let audioAssetTrack = audioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: kCMTimeZero)
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), of: audioAssetTrack, at: kCMTimeZero)
        }catch{
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
        
        let preset: String = AVAssetExportPreset1280x720
        
        guard
            let assetExport = AVAssetExportSession(asset: mixComposition, presetName: preset),
            assetExport.supportedFileTypes.contains(AVFileType.mp4) else {
                SVProgressHUD.dismiss()
                return
        }
        
        var tempFileUrl = checkExistanceAndRename()
        
        tempFileUrl = URL(fileURLWithPath: tempFileUrl.path)
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = tempFileUrl
        assetExport.shouldOptimizeForNetworkUse = true
        assetExport.exportAsynchronously {
            
            let uuid = NSUUID().uuidString
            let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("\(uuid).mp4")
            
            do {
                let fileManager = FileManager.default
                
                // Check if file exists
                if fileManager.fileExists(atPath: outputFilePath) {
                    // Delete file
                    try fileManager.removeItem(atPath: outputFilePath)
                } else {
                    print("File does not exist")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
            
            self.finalPath = URL(fileURLWithPath: outputFilePath)
            HBRecorder.saveVideo(tempFileUrl, withTo: self.finalPath)
            SVProgressHUD.dismiss()
            
            // Do any additional setup after loading the view.
            DispatchQueue.main.async(execute: {
                //Run UI Updates
                self.perform(#selector(self.reviewVideo), with: nil, afterDelay: 0.5)
            })
        }
    }
    
    func mergeFilesWithUrl_WaterMark(videoUrl:URL, audioUrl:URL, waterUrl:URL)
    {
        SVProgressHUD.show()
        let mixComposition = AVMutableComposition()
        let totalVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionBackTrack : [AVMutableCompositionTrack] = []
        
        let videoAsset = AVAsset(url: waterUrl)
        let audioAsset = AVAsset(url: audioUrl)
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionBackTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let audioAssetTrack = audioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: kCMTimeZero)
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), of: audioAssetTrack, at: kCMTimeZero)
        }catch{
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
        
        let preset: String = AVAssetExportPreset1280x720
        
        guard
            let assetExport = AVAssetExportSession(asset: mixComposition, presetName: preset),
            assetExport.supportedFileTypes.contains(AVFileType.mp4) else {
                SVProgressHUD.dismiss()
                return
        }
        
        var tempFileUrl = checkExistanceAndRename()
        
        tempFileUrl = URL(fileURLWithPath: tempFileUrl.path)
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = tempFileUrl
        assetExport.shouldOptimizeForNetworkUse = true
        assetExport.exportAsynchronously {
            
            let uuid = NSUUID().uuidString
            let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("\(uuid)_watermark.mp4")
            
            do {
                let fileManager = FileManager.default
                
                // Check if file exists
                if fileManager.fileExists(atPath: outputFilePath) {
                    // Delete file
                    try fileManager.removeItem(atPath: outputFilePath)
                } else {
                    print("File does not exist")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
            
            self.watermarkVideoPath = URL(fileURLWithPath: outputFilePath)
            HBRecorder.saveVideo(tempFileUrl, withTo: self.watermarkVideoPath)
            SVProgressHUD.dismiss()
            
            // Do any additional setup after loading the view.
            DispatchQueue.main.async(execute: {
                //Run UI Updates
                self.mergeFilesWithUrl(videoUrl: videoUrl, audioUrl: audioUrl)
            })
        }
    }
    
    func mergeFilesWithUrl(videoUrl:URL)
    {
        SVProgressHUD.show()
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        let videoAsset = AVAsset(url: videoUrl)
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: kCMTimeZero)
        }catch{
            
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
        
        let preset: String = AVAssetExportPreset1280x720
        
        guard
            let assetExport = AVAssetExportSession(asset: mixComposition, presetName: preset),
            assetExport.supportedFileTypes.contains(AVFileType.mp4) else {
                SVProgressHUD.dismiss()
                return
        }
        
        var tempFileUrl = videoUrl
        
        tempFileUrl = URL(fileURLWithPath: tempFileUrl.path)
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = tempFileUrl
        assetExport.shouldOptimizeForNetworkUse = true
        assetExport.exportAsynchronously {
            
            let uuid = NSUUID().uuidString
            let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("\(uuid).mp4")
            
            do {
                let fileManager = FileManager.default
                
                // Check if file exists
                if fileManager.fileExists(atPath: outputFilePath) {
                    // Delete file
                    try fileManager.removeItem(atPath: outputFilePath)
                } else {
                    print("File does not exist")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
            
            self.finalPath = URL(fileURLWithPath: outputFilePath)
            HBRecorder.saveVideo(tempFileUrl, withTo: self.finalPath)
            SVProgressHUD.dismiss()
            
            // Do any additional setup after loading the view.
            DispatchQueue.main.async(execute: {
                //Run UI Updates
                self.perform(#selector(self.reviewVideo), with: nil, afterDelay: 0.5)
            })
        }
    }
    
    func mergeFilesWithUrl_WaterMark(videoUrl:URL, waterUrl:URL)
    {
        SVProgressHUD.show()
        let mixComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        let videoAsset = AVAsset(url: waterUrl)
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: kCMTimeZero)
        }catch{
            
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
        
        let preset: String = AVAssetExportPreset1280x720
        
        guard
            let assetExport = AVAssetExportSession(asset: mixComposition, presetName: preset),
            assetExport.supportedFileTypes.contains(AVFileType.mp4) else {
                SVProgressHUD.dismiss()
                return
        }
        
        var tempFileUrl = waterUrl
        
        tempFileUrl = URL(fileURLWithPath: tempFileUrl.path)
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = tempFileUrl
        assetExport.shouldOptimizeForNetworkUse = true
        assetExport.exportAsynchronously {
            
            let uuid = NSUUID().uuidString
            let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("\(uuid)_watermark.mp4")
            
            do {
                let fileManager = FileManager.default
                
                // Check if file exists
                if fileManager.fileExists(atPath: outputFilePath) {
                    // Delete file
                    try fileManager.removeItem(atPath: outputFilePath)
                } else {
                    print("File does not exist")
                }
                
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
            
            self.watermarkVideoPath = URL(fileURLWithPath: outputFilePath)
            HBRecorder.saveVideo(tempFileUrl, withTo: self.watermarkVideoPath)
            SVProgressHUD.dismiss()
            
            // Do any additional setup after loading the view.
            DispatchQueue.main.async(execute: {
                //Run UI Updates
                self.mergeFilesWithUrl(videoUrl: videoUrl)
            })
        }
    }
    
    func addWaterMark(videoUrl:URL) {
    }
    
    func saveToAlbum() {
        
        PHPhotoLibrary.requestAuthorization({status in
            if status == .authorized{
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.watermarkVideoPath!)
                }) { saved, error in
                    SVProgressHUD.dismiss()
                    if saved {
                        DispatchQueue.main.async(execute: {
                            self.showJHTAlerttOkayWithIcon(message:"Successfully saved into Album!")
                        })
                    }
                    else {
                        self.showJHTAlerttOkayWithIcon(message:"Failed saving!")
                    }
                }
                
            } else {
                SVProgressHUD.dismiss()
            }
        })
    }
    
    func checkExistanceAndRename() -> URL
    {
        let uuid = NSUUID().uuidString
        let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("\(uuid).mp4")
        let tempFileUrl = URL(fileURLWithPath: outputFilePath)
        
        return tempFileUrl
    }
    
    func postNewVideo() {
        
        let checkConnection = RKCommon.checkInternetConnection()
        if !checkConnection {
            self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
            return
        }
        
        if self.finalPath == nil {
            return
        }
        
        
        self.uploadedVideoUrl = nil
        self.uploadedThumbnailUrl = nil
        
        SVProgressHUD.show()
        
        let path:String = "Post_Videos/feed_" + UserDefaults.standard.getUserId()! + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).mp4"
        
        self.storageRef.child(path).putFile(from: self.finalPath!, metadata: nil) { (metadata, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showJHTAlerttOkayWithIcon(message:error.localizedDescription)
            }
            else {
                let downloadURL = metadata!.downloadURL()?.absoluteString
                //let url = self.storageRef.child((metadata?.downloadURL()?.absoluteString)!).description
                self.uploadedVideoUrl = downloadURL
                DispatchQueue.main.async(execute: {
                    self.uploadThumbnail()
                })
            }
        }
    }
    
    func uploadThumbnail() {
        
        let checkConnection = RKCommon.checkInternetConnection()
        if !checkConnection {
            self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
            return
        }
        
        if self.thumbnail == nil {
            return
        }
        
        SVProgressHUD.show()
        
        let path:String = "Post_Thumbnails/feed_" + UserDefaults.standard.getUserId()! + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let data = UIImageJPEGRepresentation(self.thumbnail, 0.5)
        self.storageRef.child(path).putData(data!, metadata: nil) { (metadata, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showJHTAlerttOkayWithIcon(message:error.localizedDescription)
            }
            else {
                let downloadURL = metadata!.downloadURL()?.absoluteString
                self.uploadedThumbnailUrl = downloadURL
                DispatchQueue.main.async(execute: {
                    self.addToFireDB()
                    self.showJHTAlerttOkayWithIcon(message:"Successfully posted!")
                })
            }
        }
    }
    
    func addToFireDB() {
        
        if self.uploadedVideoUrl == nil || self.uploadedThumbnailUrl == nil {
            return
        }
        
        let userid = UserDefaults.standard.getUserId()! as String
        let id = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let feedRef = Database.database().reference().child("feeds/\(id)")
        
        var username = UserDefaults.standard.getUsername()
        if username == nil {
            username = ""
        }
        var photo = UserDefaults.standard.getUserPhotoUrl()
        if photo == nil {
            photo = ""
        }
        var email = UserDefaults.standard.getEmail()
        if email == nil {
            email = ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createtime = dateFormatter.string(from: NSDate() as Date)
        
        let feedItem = [
            "id": "\(id)",
            "create_date": createtime,
            "thumbnail_url": self.uploadedThumbnailUrl,
            "video_url": self.uploadedVideoUrl,
            "userid": userid,
            "username":username,
            "useremail":email,
            "userphoto":photo,
            //            "upvoteCount":"0",
            "songtitle":self.songTitle
        ]
        feedRef.setValue(feedItem)
        
        let userRef = Database.database().reference().child("users")
        userRefH = userRef.queryOrdered(byChild: "userId").queryEqual(toValue: userid).observe(.value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                
                var userData = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                if userData["spotCount"] == nil {
                    userData["spotCount"] = "1" as AnyObject
                }
                else {
                    let count = userData["spotCount"] as! String
                    userData["spotCount"] = "\(Int(count)!+1)" as AnyObject
                }
                userRef.removeObserver(withHandle: self.userRefH)
                userRef.child(userid).setValue(userData)
                self.gotoCameraView()
                self.updateSongIndex()
                break
            }
        })
    }
    
    func getAudioPath() -> URL? {
        
        var audioPath = ""
        
//        if UserDefaults.standard.object(forKey: "recording_index")  == nil {
//            return audioPath
//        }
//        let recordIdx = UserDefaults.standard.object(forKey: "recording_index") as! String
//        let idx:Int = Int(recordIdx)!
//
//        var arrIds:[String] = []
//        let songIds = UserDefaults.standard.object(forKey: "trimed_songid") as! String
//        if songIds.characters.count > 0 {
//            let arr = songIds.split(separator: ",")
//            for idx in arr {
//                arrIds.append(String(idx))
//            }
//        }
//
//        var count:Int = 0
//        for songId in arrIds {
//            if UserDefaults.standard.object(forKey: "\(songId)_cropped") != nil {
//                let cropped = UserDefaults.standard.object(forKey: "\(songId)_cropped") as! String
//                if cropped == "1" {
//                    if idx == count {
//                        let path = UserDefaults.standard.object(forKey: "\(songId)_path") as! String
//                        audioPath = path
//                        let title = UserDefaults.standard.object(forKey: "\(songId)_title") as! String
//                        self.songTitle = title
//                        break
//                    }
//                    count += 1
//                }
//            }
//        }
        
        guard let audioUrl = URL(string: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview20/v4/d4/af/de/d4afdeb1-5332-ec74-7d46-6b1226285afd/mzaf_7170620687588028996.plus.aac.p.m4a") else { return nil }
        
        guard let docmentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        let destinationUrl = docmentDirectoryUrl.appendingPathComponent(audioUrl.lastPathComponent)
        print("destinationUrl", destinationUrl)
        
//        if FileManager.default.fileExists(atPath: destinationUrl.path) {
//            print("The file already exists at path")
//        } else {
//            
//            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) in
//                
//                guard let location = location, error == nil else { return }
//                do {
//                    
//                    try FileManager.default.moveItem(at: location, to: destinationUrl)
//                    
//                    
//                } catch let error {
//                    print(error.localizedDescription)
//                }
//                
//                
//            }).resume()
//            
//        }
        return destinationUrl
//        return audioPath
    }
    
    func updateSongIndex() {
        var arrIds:[String] = []
        if UserDefaults.standard.object(forKey: "trimed_songid") == nil {
            return
        }
        var songIds = UserDefaults.standard.object(forKey: "trimed_songid") as! String
        if songIds.characters.count > 0 {
            let arr = songIds.split(separator: ",")
            for ids in arr {
                arrIds.append(String(ids))
            }
        }
        if arrIds.count < 2 {
            return
        }
        
        let firstSongid = arrIds[0]
        var newSongIds = ""
        for var arr in arrIds {
            if arr == firstSongid {
                continue
            }
            if newSongIds.characters.count > 0 {
                newSongIds = "\(newSongIds),\(arr)"
            }
            else {
                newSongIds = "\(arr)"
            }
        }
        newSongIds = "\(newSongIds),\(firstSongid)"
        
        UserDefaults.standard.set(newSongIds, forKey: "trimed_songid")
        UserDefaults.standard.synchronize()
    }
    
}
