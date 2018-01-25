//
//  RecordViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import SVProgressHUD
import Instructions
import Photos
import AVFoundation

class RecordViewController: HBRecorder, HBRecorderProtocol {

    var coachMarksController = CoachMarksController()

    var videoPath: URL?
    
    let color1 = UIColor(red: 95/255.0, green: 161/255.0, blue: 255/255.0, alpha: 1.0)
    let color2 = UIColor(red: 95/255.0, green: 255/255.0, blue: 184/255.0, alpha: 1.0)
    let color3 = UIColor(red: 201/255.0, green: 95/255.0, blue: 255/255.0, alpha: 1.0)
    let color4 = UIColor(red: 255/255.0, green: 95/255.0, blue: 95/255.0, alpha: 1.0)
    let color5 = UIColor(red: 95/255.0, green: 237/255.0, blue: 255/255.0, alpha: 1.0)
    let color6 = UIColor(red: 119/255.0, green: 255/255.0, blue: 95/255.0, alpha: 1.0)
    let color7 = UIColor(red: 255/255.0, green: 95/255.0, blue: 168/255.0, alpha: 1.0)
    
    let color8 = UIColor(red: 95/255.0, green: 140/255.0, blue: 253/255.0, alpha: 1.0)
    let color9 = UIColor(red: 255/255.0, green: 95/255.0, blue: 95/255.0, alpha: 1.0)
    let color10 = UIColor(red: 255/255.0, green: 95/255.0, blue: 221/255.0, alpha: 1.0)
    let color11 = UIColor(red: 140/255.0, green: 255/255.0, blue: 106/255.0, alpha: 1.0)
    let color12 = UIColor(red: 95/255.0, green: 237/255.0, blue: 255/255.0, alpha: 1.0)
    let color13 = UIColor(red: 219/255.0, green: 95/255.0, blue: 255/255.0, alpha: 1.0)
    
    @IBOutlet var imgProgress: UIImageView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var imgCapBtn: UIImageView!
    @IBOutlet var lbSongTitle:UILabel!
    @IBOutlet var swipeRight: UIView!
    @IBOutlet var swipeLeft: UIView!
    
    let imgProgressText = "Current Shot"
    let imgCapBtnText = "Shot Length"
    let swipeRigthText = "Swipe right for music"
    let swipeLeftText = "Swipe left for social"
    
    var arrColors:[UIColor] = []
    var selColor:UIColor = UIColor.white
    
    var arrDuration:[Int] = [3,2,2,1,1]
    var selDuration:Int = 0
    var selDurationIndex = 0
    
    static var sharedCamInstance:RecordViewController? = nil
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                gotoMusicView()
                break
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                break
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                if self.recorder.isRecording {
                    self.showJHTAlerttOkayWithIcon(message:"When is recording, you can't swipe!")
                    return
                }
                let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "maintab")
                AnimationVC.pushView(self, toVC: VC, toRight: true)
                break
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                break
            default:
                break
            }
        }
    }
    
    @objc func gotoMusicView() {
        if self.recorder.isRecording {
            self.showJHTAlerttOkayWithIcon(message:"When is recording, you can't swipe!")
            return
        }
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "musicView") as! MusicViewController
        let navVC = UINavigationController(rootViewController: VC)
        AnimationVC.pushView(self, toVC: navVC, toRight: false)
    }
    
    @IBAction func switchFlashButton(_ sender: Any) {
        switchFlashProc()
        if super.isFlashButtonOn() == true {
            self.flashModeButton.setImage(UIImage(named: "FlashOn"), for: .normal)
        } else {
            self.flashModeButton.setImage(UIImage(named: "FlashOff"), for: .normal)
        }
    }
    override func switchFlashProc() {
        super.switchFlashProc()
    }
    
    func removeChildViews() {
        
        if let vc1 = ReviewVideoController.sharedReview {
            vc1.navigationController?.popViewController(animated: false)
            initData()
        }
        
        if let vc2 = MainTabbarController.sharedHome {
            vc2.dismiss(animated: false, completion: nil)
        }
        
        if let vc3 = MusicViewController.sharedMusic {
            vc3.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let audioUrl = URL(string: "https://audio-ssl.itunes.apple.com/apple-assets-us-std-000001/AudioPreview20/v4/d4/af/de/d4afdeb1-5332-ec74-7d46-6b1226285afd/mzaf_7170620687588028996.plus.aac.p.m4a") else { return }
        
        guard let docmentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let destinationUrl = docmentDirectoryUrl.appendingPathComponent(audioUrl.lastPathComponent)
        print("destinationUrl", destinationUrl)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
        } else {
            
            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) in
                
                guard let location = location, error == nil else {
                    
//                    print("location", location)
                    print("error", error?.localizedDescription)
                    
                    return }
                do {
                    
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                
                
            }).resume()
            
        }
        
        
        
        
        RecordViewController.sharedCamInstance = self

        self.navigationController?.isNavigationBarHidden = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        arrColors.append(color1)
        arrColors.append(color2)
        arrColors.append(color3)
        arrColors.append(color4)
        arrColors.append(color5)
        arrColors.append(color6)
        arrColors.append(color7)
        arrColors.append(color8)
        arrColors.append(color9)
        arrColors.append(color10)
        arrColors.append(color11)
        arrColors.append(color12)
        arrColors.append(color13)
        
        imgCapBtn.layer.borderColor = selColor.cgColor
        imgCapBtn.layer.borderWidth = 6
        imgCapBtn.layer.cornerRadius = imgCapBtn.frame.size.width/2
        imgCapBtn.layer.masksToBounds = true
        
        SVProgressHUD.dismiss()
        self.initData()

        self.recBtn.backgroundColor = UIColor.white
        self.recBtn.layer.cornerRadius = self.recBtn.frame.size.width/2
        self.recBtn.layer.masksToBounds = true
        self.btnBack.isHidden = true
        
        self.coachMarksController.overlay.allowTap = true
        self.coachMarksController.dataSource = self
        if UserDefaults.standard.bool(forKey: "shownWalkthrough") == false {
            UserDefaults.standard.set(true, forKey: "shownWalkthrough")
            self.coachMarksController.start(on: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.lbSongTitle != nil {
            self.lbSongTitle.text = self.getSongTitle()
        }
        updateTakeUI()
    }
    
    func clearTempVideoFiles() {
        
        let fileManager = FileManager.default
        let tempDirPath = NSTemporaryDirectory() as NSString
        do {
            let directoryContents = try fileManager.contentsOfDirectory(atPath: tempDirPath as String) as NSArray?
            if directoryContents != nil {
                for path in directoryContents! {
                    let fullPath = tempDirPath.appendingPathComponent(path as! String)
                    let lpath = fullPath.lowercased()
                    if lpath.contains(".mov") || lpath.contains(".mp4") {
                        do {
                            try fileManager.removeItem(atPath: fullPath)
                        } catch {
                            print("Could not delete file!")
                        }
                    }
                }
            } else {
                print("Could not retrieve directory!")
            }
        } catch  {
        }
    }
    
    @objc public func initData() {
        
        arrDuration = [3,2,2,1,1]
        selDuration = 0
        selDurationIndex = 0
        
        let uname = UserDefaults.standard.getUsername()

        self.delegate = self
        self.topTitle = ""
        self.bottomTitle = uname
        self.maxRecordDuration = 15
        self.maxSegmentDurations = []
        self.movieName = "MyAnimatedMovie"
        self.flashModeButton.isHidden = false
        self.timeRecordedLabel.isHidden = true
        self.currentRecord = 0
        self.timeRecordedLabel.text = "0"
        
        let imageBar = "recodring_step\(0)"
        self.imgProgress.image = UIImage(named:imageBar)
        
        var arr:[Int] = [3]
        for i in 0...4 {
            let duration = self.getDurationValue(i)
            arr.append(duration)
        }
        arr.append(3)
        self.maxSegmentDurations = NSMutableArray(array: arr)
        
        selColor = arrColors[0]
        lbRecDuration.textColor = selColor
        lbRecDuration.text = "\(arr[0])"
        imgCapBtn.layer.borderColor = selColor.cgColor
        
        self.lbSongTitle.text = self.getSongTitle()
        
        clearTempVideoFiles()
        
        SVProgressHUD.dismiss()
    }
    
    func getSongTitle() ->String {
        
        var title = "No Song Selected - Director Mode"
        
        if UserDefaults.standard.object(forKey: "recording_index") == nil {
            return title
        }
        let recordIdx = UserDefaults.standard.object(forKey: "recording_index") as! String
        let idx:Int = Int(recordIdx)!
        
        var arrIds:[String] = []
        let songIds = UserDefaults.standard.object(forKey: "trimed_songid") as! String
        if songIds.characters.count > 0 {
            let arr = songIds.split(separator: ",")
            for idx in arr {
                arrIds.append(String(idx))
            }
        }
        
        var count:Int = 0
        for songId in arrIds {
            
            if UserDefaults.standard.object(forKey: "\(songId)_cropped") != nil {
                let cropped = UserDefaults.standard.object(forKey: "\(songId)_cropped") as! String
                if cropped == "1" {
                    if idx == count {
                        title = UserDefaults.standard.object(forKey: "\(songId)_title") as! String
                        break
                    }
                    count += 1
                }
            }
        }
        
        return title
    }
    
    func getDurationValue(_ idx:Int) -> Int {
        if idx < 4 {
            selDurationIndex = Range(0 ... 4-idx).randomInt
        }
        else {
            selDurationIndex = 0
        }
        selDuration = arrDuration[selDurationIndex]
        arrDuration.remove(at: selDurationIndex)
        return selDuration
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickedClose(_ sender: Any) {
        if self.recorder.isRecording == true || self.currentRecord == 0 {
            return
        }
        
        self.retakeShot()
        updateTakeUI()
        let imageBar = "recodring_step\(self.currentRecord)"
        self.imgProgress.image = UIImage(named:imageBar)
        lbRecDuration.text = "\(Int(truncating: self.maxSegmentDurations.object(at: Int(self.currentRecord)) as! NSNumber))"
    }

    @objc func gotoReviewVideo(_ thumbnail:UIImage) {
        
        let mergeVC = self.storyboard?.instantiateViewController(withIdentifier: "reviewView") as! ReviewVideoController
        mergeVC.parentVC = self
        mergeVC.thumbnail = thumbnail
        self.navigationController?.pushViewController(mergeVC, animated: true)
    }
    
    func recorder(_ recorder: HBRecorder, didFinishPickingMediaWith videoUrl: URL, watermarkUrl: URL) {
        videoPath = videoUrl
        
        UserDefaults.standard.set(videoUrl, forKey: "video_merged")
        UserDefaults.standard.set(watermarkUrl, forKey: "video_watermark")
        UserDefaults.standard.synchronize()

        SVProgressHUD.dismiss()
        
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            let asset = AVAsset(url: self.videoPath!)
            // url= give your url video here
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time: CMTime = CMTimeMake(2, 5)
            //it will create the thumbnail after the 5 sec of video
            let imageRef: CGImage? = try? imageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: imageRef!)
            
            DispatchQueue.main.async(execute: {                
                //Run UI Updates
                self.perform(#selector(self.gotoReviewVideo), with: thumbnail, afterDelay: 0.1)
            })
        })

        print("VideoPath : + \(String(describing: videoPath))")
        
    }
    
    func recorderDidCancel(_ recorder: HBRecorder) {
        print("Recorder did cancel..")
    }
    
    func recorderUpdateProgress(_ recorder: HBRecorder) {
        let imageBar = "recodring_step\(self.currentRecord)"
        self.imgProgress.image = UIImage(named:imageBar)

        self.perform(#selector(self.updateTakeUI), with: nil, afterDelay: 1.0)

        if self.currentRecord > 6 {
            SVProgressHUD.show()
            self.perform(#selector(self.stopRecordingVideo), with: nil, afterDelay: 1.0)
        }
    }
    
    func recorderBegin(_ recorder: HBRecorder) -> Bool {
        return true
    }
    
    @objc func updateTakeUI() {
        if self.currentRecord == 0 {
            btnBack.isHidden = true
        } else {
            btnBack.isHidden = false
        }
        if self.currentRecord < arrColors.count {
            
            let idx = Int(self.currentRecord)
            selColor = arrColors[idx]
            lbRecDuration.textColor = selColor
            imgCapBtn.layer.borderColor = selColor.cgColor
        }
    }
    
    func checkCroppedAudio() ->Bool {
        
        if UserDefaults.standard.object(forKey: "trimed_songid") == nil {
            return false
        }
        
        var arrIds:[String] = []
        let songIds = UserDefaults.standard.object(forKey: "trimed_songid") as! String
        if songIds.characters.count > 0 {
            let arr = songIds.split(separator: ",")
            for idx in arr {
                arrIds.append(String(idx))
            }
        }
        
        var count:Int = 0
        for songId in arrIds {
            
            if UserDefaults.standard.object(forKey: "\(songId)_cropped") != nil {
                let cropped = UserDefaults.standard.object(forKey: "\(songId)_cropped") as! String
                if cropped == "1" {
                    count += 1
                }
            }
        }
        
        if count > 0 {
            return true
        }
        return false
    }
    
    
}

extension Range
{
    var randomInt: Int
    {
        get
        {
            var offset = 0
            
            if (lowerBound as! Int) < 0   // allow negative ranges
            {
                offset = abs(lowerBound as! Int)
            }
            
            let mini = UInt32(lowerBound as! Int + offset)
            let maxi = UInt32(upperBound as! Int + offset)
            
            return Int(mini + arc4random_uniform(maxi - mini)) - offset
        }
    }
}


extension RecordViewController: CoachMarksControllerDataSource {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 4
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch(index) {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: self.imgProgress)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: self.imgCapBtn) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                return UIBezierPath(ovalIn: frame.insetBy(dx: -4, dy: -4))
            }
        case 2:
            return coachMarksController.helper.makeCoachMark(for: self.swipeRight)
        case 3:
            return coachMarksController.helper.makeCoachMark(for: self.swipeLeft)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        var hintText = ""
        
        switch(index) {
        case 0:
            hintText = self.imgProgressText
        case 1:
            hintText = self.imgCapBtnText
        case 2:
            hintText = self.swipeLeftText
        case 3:
            hintText = self.swipeRigthText
        default: break
        }
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation, hintText: hintText, nextText: nil)
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}
