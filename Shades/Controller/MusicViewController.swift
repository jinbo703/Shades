//
//  MusicViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation
import SVProgressHUD

class MusicViewController: UIViewController {
    
    @IBOutlet var tblList:UITableView!
    @IBOutlet var tfSearch:UITextField!
    @IBOutlet var lbMusicHint:UILabel!
    @IBOutlet var viewOverlay:UIView!
    @IBOutlet var viewSelectPortion:UIView!
    @IBOutlet var btnDone:UIButton!
    
    var cropVC:IQAudioCropperViewController!

    var arrData:[SongInfo] = []
    var arrTrimed:[SongInfo] = []
    var arrUnTrimed:[SongInfo] = []
    var arrSearch:[SongInfo] = []
    var selectedSong:SongInfo!
    
    var selectedIndex:Int = -1
    
    var tableSections:[String] = ["Up next", "Songs"]
    
    var songQuery: SongQuery = SongQuery()
    
    static var sharedMusic:MusicViewController? = nil
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                break
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                break
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                AnimationVC.popView(self, toRight: true)
                MusicViewController.sharedMusic = nil
                break
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                break
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        MusicViewController.sharedMusic = self
        
        btnDone.layer.borderColor = UIColor(red: 255/255.0, green: 4/255.0, blue: 22/255.0, alpha: 1.0).cgColor
        btnDone.layer.borderWidth = 3
        btnDone.layer.cornerRadius = btnDone.frame.size.width/2
        btnDone.layer.masksToBounds = true
        btnDone.isHidden = true
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressGestureRecognized))
        tblList.addGestureRecognizer(longpress)
    }
    
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        
        if self.arrTrimed.count < 1 {
            return
        }
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: tblList)
        let locationOnScreen = longPress.location(in: tblList.superview)
        let listCount = self.arrTrimed.count
        
        if tblList.indexPathForRow(at: locationInView) == nil {
            if Path.initialIndexPath == nil {
                if My.cellSnapshot != nil {
                    My.cellSnapshot!.removeFromSuperview()
                    My.cellSnapshot = nil
                }
                tblList.reloadData()
                return
            }
            let cell = tblList.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                My.cellSnapshot!.center = (cell?.center)!
                My.cellSnapshot!.transform = CGAffineTransform.identity
                My.cellSnapshot!.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    if My.cellSnapshot != nil {
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                }
            })
            tblList.reloadData()
            return
        }
        
        var indexPath:NSIndexPath! = nil
        
        do {
            try indexPath = (tblList.indexPathForRow(at: locationInView)! as NSIndexPath?)!
//            print("indexpath Section - \(indexPath.section)")
            if self.arrTrimed.count > 0 {
                if indexPath.section > 0 {
                    return
                }
            }
        }
        catch {
            return
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            
            Path.initialIndexPath = indexPath
            let cell = tblList.cellForRow(at: indexPath as IndexPath) as UITableViewCell!
            My.cellSnapshot  = snapshopOfCell(inputView: cell!)
            var center = cell?.center
            My.cellSnapshot!.center = center!
            My.cellSnapshot!.alpha = 0.0
            tblList.addSubview(My.cellSnapshot!)
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                center?.y = locationInView.y
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                My.cellSnapshot!.alpha = 0.98
                cell?.alpha = 0.0
                
            }, completion: { (finished) -> Void in
                if finished {
                    cell?.isHidden = true
                }
            })
        
            break
        
        case UIGestureRecognizerState.changed:
            var center = My.cellSnapshot!.center
            center.y = locationInView.y
            My.cellSnapshot!.center = center
            if indexPath != Path.initialIndexPath {
                let id1 = indexPath.row as Int
                let id2 = (Path.initialIndexPath?.row)! as Int
                let item1 = self.arrTrimed[id1]
                let item2 = self.arrTrimed[id2]
                self.arrTrimed[id1] = item2
                self.arrTrimed[id2] = item1
                tblList.moveRow(at: Path.initialIndexPath! as IndexPath, to: indexPath as IndexPath)
                Path.initialIndexPath = indexPath
            }
            if locationOnScreen.y < 200 && indexPath.row > 1 {
                let indexPath = NSIndexPath(row: indexPath.row-1, section: 0)
                tblList.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.top, animated: true)
            } else if locationOnScreen.y > 550 && indexPath.row < listCount-1 {
                let indexPath = NSIndexPath(row: indexPath.row+1, section: 0)
                tblList.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
            
        case .ended:
            updateOrder()
            let cell = tblList.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                My.cellSnapshot!.center = (cell?.center)!
                My.cellSnapshot!.transform = CGAffineTransform.identity
                My.cellSnapshot!.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    My.cellSnapshot!.removeFromSuperview()
                    My.cellSnapshot = nil
                }
            })
            break
        
        default:
            let cell = tblList.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                My.cellSnapshot!.center = (cell?.center)!
                My.cellSnapshot!.transform = CGAffineTransform.identity
                My.cellSnapshot!.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    My.cellSnapshot!.removeFromSuperview()
                    My.cellSnapshot = nil
                }
            })
        }
    }
    
    func updateOrder() {
        
        var songIds = ""
        for item in self.arrTrimed {
            let songId = "\(item.songId)"
            if songIds.characters.count < 1 {
                songIds = "\(songId)"
            }
            else {
                songIds = "\(songIds),\(songId)"
            }
        }
        UserDefaults.standard.set(songIds, forKey: "trimed_songid")
        UserDefaults.standard.set("0", forKey: "recording_index")
        UserDefaults.standard.synchronize()
        
        self.tblList.reloadData()
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SVProgressHUD.show()
        self.perform(#selector(self.getMusicData), with: nil, afterDelay: 0.5)
    }
    
    @objc func getMusicData() {
        
        self.arrData.removeAll()
        self.arrTrimed.removeAll()
        self.arrUnTrimed.removeAll()
        self.arrSearch.removeAll()

        var arrIds:[String] = []
        if UserDefaults.standard.object(forKey: "trimed_songid") != nil {
            let songIds = UserDefaults.standard.object(forKey: "trimed_songid") as! String
            if songIds.characters.count > 0 {
                let arr = songIds.split(separator: ",")
                for idx in arr {
                    arrIds.append(String(idx))
                }
            }
        }
        if #available(iOS 9.3, *) {
            MPMediaLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    self.arrData = self.songQuery.get2(songCategory: "")
                    
                    for sId in arrIds {
                        for item in self.arrData {
                            let songId = "\(item.songId)"
                            if sId == songId {
                                self.arrTrimed.append(item)
                                break
                            }
                        }
                    }

                    for item in self.arrData {
                        let songId = "\(item.songId)"
                        var bExist = false
                        for sId in arrIds {
                            if sId == songId {
                                bExist = true
                                break
                            }
                        }
                        if bExist == false {
                            self.arrUnTrimed.append(item)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        for item in self.arrUnTrimed {
                            self.arrSearch.append(item)
                        }
                        self.tblList?.reloadData()
                    }
                } else {
                }
                SVProgressHUD.dismiss()
            }
        } else {
            // Fallback on earlier versions
            SVProgressHUD.dismiss()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func untrimSong(_ sender: UIButton) {
        
        let songId = self.arrTrimed[sender.tag].songId
        let path = UserDefaults.standard.object(forKey: "\(songId)_path") as! String!
        let fullPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(path!)
        if FileManager.default.fileExists(atPath: fullPath) == true {
            do {
                try FileManager.default.removeItem(atPath: fullPath)
            } catch {
                print("Could not delete file!")
            }
        }
        
        UserDefaults.standard.set("", forKey: "\(songId)_path")
        UserDefaults.standard.set("0", forKey: "\(songId)_cropped")
        UserDefaults.standard.set("", forKey: "\(songId)_title")
        
        if UserDefaults.standard.object(forKey: "trimed_songid") != nil {
            var songIds = UserDefaults.standard.object(forKey: "trimed_songid") as! String
            songIds = songIds.replacingOccurrences(of: ",\(songId)", with: "")
            songIds = songIds.replacingOccurrences(of: "\(songId),", with: "")
            songIds = songIds.replacingOccurrences(of: "\(songId)", with: "")
            
            UserDefaults.standard.set(songIds, forKey: "trimed_songid")
        }
        
        UserDefaults.standard.set("0", forKey: "recording_index")
        UserDefaults.standard.synchronize()
        
        let item = self.arrTrimed[sender.tag]
        self.arrSearch.append(item)
        self.arrUnTrimed.append(item)
        self.arrTrimed.remove(at: sender.tag)
        
        self.tblList.reloadData()
    }
    
    @objc func trimSong(_ sender: UIButton) {
        
        selectedIndex = sender.tag
        selectedSong = self.arrSearch[selectedIndex]
        
        addCropMusicView(selectedSong)
    }
    
    func addCropMusicView(_ song: SongInfo) {
        
        if let filePath = song.songUrl as URL? {
            
            viewOverlay.isHidden = false
            cropVC = IQAudioCropperViewController(fileUrl: filePath)
            cropVC.delegate = self
            cropVC.parentVC = self
            cropVC.frameView = self.viewSelectPortion.bounds
            
            self.addChildViewController(cropVC)
            self.viewSelectPortion.addSubview(cropVC.view)
            
        }
    }
    
    @IBAction func onClickedCancelCrop(_ sender: Any) {
        self.navigationController?.isToolbarHidden = true
        
        cropVC.stopPlayingButtonAction(nil)
        cropVC.view.removeFromSuperview()
        cropVC.removeFromParentViewController()
        viewOverlay.isHidden = true
        self.btnDone.isHidden = true
    }
    
    @IBAction func onClickedCheckDone(_ sender: Any) {
        cropVC.notifySuccessDelegate()
    }
    

}

extension MusicViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField.text == nil {
            return true
        }
        
        SVProgressHUD.show()
        let key = textField.text?.lowercased()
        self.perform(#selector(self.searchSongs(_:)), with: key, afterDelay: 1.0)

        return true
    }
    
    @objc func searchSongs(_ key:String) {
        
        self.arrSearch.removeAll()
        
        for item in self.arrUnTrimed {
            
            let title = item.songTitle.lowercased()
            if (key.characters.count) < 1 || title.contains(key) {
                self.arrSearch.append(item)
            }
        }
        self.tblList.reloadData()
        SVProgressHUD.dismiss()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        lbMusicHint.isHidden = true
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text == "" {
            lbMusicHint.isHidden = false
        }
    }
}

extension MusicViewController: IQAudioCropperViewControllerDelegate {
    
    func audioCropperController(_ controller: IQAudioCropperViewController, didFinishWithAudioAtPath filePath: String) {
        
        let songId = selectedSong.songId
        var arrPath = filePath.split(separator: "/")
        if arrPath.count > 0 {
            let path = arrPath[Int(arrPath.count-1)]
            UserDefaults.standard.set(path, forKey: "\(songId)_path")
        }
        UserDefaults.standard.set(selectedSong.songTitle, forKey: "\(songId)_title")
        UserDefaults.standard.set("1", forKey: "\(songId)_cropped")
        UserDefaults.standard.set("0", forKey: "recording_index")
        
        var songIds = ""
        if UserDefaults.standard.object(forKey: "trimed_songid") != nil {
            songIds = UserDefaults.standard.object(forKey: "trimed_songid") as! String
            if songIds.characters.count > 0 {
                songIds = "\(songIds),\(songId)"
            }
            else {
                songIds = "\(songId)"
            }
            UserDefaults.standard.set(songIds, forKey: "trimed_songid")
        }
        else {
            songIds = "\(songId)"
            UserDefaults.standard.set(songIds, forKey: "trimed_songid")
        }
        
        UserDefaults.standard.synchronize()
        
        self.arrTrimed.append(selectedSong)
        self.arrSearch.remove(at: selectedIndex)
        
        for item in self.arrUnTrimed {
            
            let songId2 = "\(item.songId)"
            if songId2 == "\(songId)" {
                self.arrUnTrimed.remove(at: selectedIndex)
                break
            }
        }
        
        self.navigationController?.isToolbarHidden = true
        
        cropVC.stopPlayingButtonAction(nil)
        cropVC.view.removeFromSuperview()
        cropVC.removeFromParentViewController()
        viewOverlay.isHidden = true
        self.btnDone.isHidden = true
        
        self.tblList.reloadData()
        let indexPath = IndexPath(row: 0, section: 0)
        self.tblList.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func audioCropperControllerDidCrop(_ controller: IQAudioCropperViewController) {
        self.btnDone.isHidden = false
    }
    
    func audioCropperControllerDidLoad(_ controller: IQAudioCropperViewController) {
        
        DispatchQueue.main.async(execute: {
            self.showToolbar()
        })
    }
    
    @objc func showToolbar() {
        
        if viewOverlay.isHidden == false {
            self.navigationController?.isToolbarHidden = false
        }
    }
}

extension MusicViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.arrTrimed.count > 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let vHeader = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        vHeader.backgroundColor = UIColor(red: 62/255.0, green: 65/255.0, blue: 86/255.0, alpha: 1)

        let lbTitle = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width-20, height: 60))
        lbTitle.backgroundColor = UIColor.clear
        lbTitle.textColor = UIColor.white
        lbTitle.font = UIFont.boldSystemFont(ofSize: 24)
        
        if self.arrTrimed.count > 0 {
            lbTitle.text = self.tableSections[section]
        }
        else {
            lbTitle.text = self.tableSections[1]
        }
        vHeader.addSubview(lbTitle)
        return vHeader
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.arrTrimed.count > 0 {
            return self.tableSections[section]
        }
        return self.tableSections[1]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.arrTrimed.count > 0 {
            if section == 0 {
                return self.arrTrimed.count
            }
            else {
                return self.arrSearch.count
            }
        }
        else {
            return self.arrSearch.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (Bundle.main.loadNibNamed("MusicViewCell", owner: self, options: nil)![0]) as! MusicViewCell

        var bUntrimed = true
        var songItem:SongInfo! = nil
        if self.arrTrimed.count > 0 {
            if indexPath.section == 0 {
                bUntrimed = false
                songItem = self.arrTrimed[indexPath.row]
                cell.btnDel.setBackgroundImage(UIImage(named:"checked"), for: UIControlState.normal)
                cell.btnDel.tag = indexPath.row
                cell.btnDel.addTarget(self, action: #selector(self.untrimSong(_:)), for:UIControlEvents.touchUpInside)
                cell.lbTitle?.text = "\(indexPath.row+1). \(songItem.songTitle)"
            }
        }
        
        if bUntrimed == true {
            songItem = self.arrSearch[indexPath.row]
            cell.btnDel.setBackgroundImage(UIImage(named:"add_song"), for: UIControlState.normal)
            cell.btnDel.tag = indexPath.row
            cell.btnDel.addTarget(self, action: #selector(self.trimSong(_:)), for:UIControlEvents.touchUpInside)
            cell.lbTitle?.text = songItem.songTitle
        }

        cell.lbDesc?.text = songItem.artistName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

