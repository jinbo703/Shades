//
//  FollowingViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class FollowingViewController: UIViewController {
    
    @IBOutlet var tblList:UITableView!
    @IBOutlet var userPhoto:UIButton!
    @IBOutlet var lbDate:UILabel!
    
    var arrData:[Dictionary<String, AnyObject>] = []
    
    var feedRefH:DatabaseHandle! = nil
    var feedRef: DatabaseReference!
    
    var userRefH:DatabaseHandle! = nil
    var userRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        userPhoto.layer.cornerRadius = userPhoto.frame.size.width/2
        userPhoto.layer.masksToBounds = true
        
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func getData() {
        
        let checkConnection = RKCommon.checkInternetConnection()
        if !checkConnection {
            self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
            return
        }
        
        self.arrData.removeAll()
        DispatchQueue.main.async(execute: {
            self.tblList.reloadData()
        })
        
        self.feedRef = Database.database().reference().child("feeds")
        self.feedRef.queryOrdered(byChild: "create_date").queryLimited(toLast: 50).observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                let feedData = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                
                let userId = feedData["userid"] as! String
                let myId = UserDefaults.standard.getUserId()
                let feedId = feedData["id"] as! String
                
                self.userRef = Database.database().reference().child("users")
                self.userRef.queryOrderedByKey().queryEqual(toValue: myId).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
                    for snap in snapshot.children {
                        let userInfo = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                        var blocked:Bool = false
                        if userInfo["blocks"] != nil {
                            let blockInfo = userInfo["blocks"] as! Dictionary<String, AnyObject>
                            if blockInfo[userId] != nil {
                                blocked = true
                            }
                        }
                        var reported:Bool = false
                        if userInfo["reports"] != nil {
                            let reportInfo = userInfo["reports"] as! Dictionary<String, AnyObject>
                            if reportInfo[feedId] != nil {
                                reported = true
                            }
                        }
                        
                        var following:Bool = false
                        if userInfo["following"] != nil {
                            let followingInfo = userInfo["following"] as! Dictionary<String, AnyObject>
                            if followingInfo[userId] != nil {
                                following = true
                            }
                        }
                        
                        if blocked == false && reported == false && following == true {
                            let createdTime = feedData["create_date"] as! String
                            if MainTabbarController.sharedMain.checkOldItem(createdTime) == true {
                                let id = feedData["id"] as! String
                                Database.database().reference().child("feeds").child(id).setValue(nil)
                            }
                            else {
                                self.arrData.insert(feedData, at: 0)
                                DispatchQueue.main.async(execute: {
                                    self.tblList.reloadData()
                                })
                            }
                        }
                        break;
                    }
                })
            }
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        self.perform(#selector(self.displayDate), with: nil, with: 1.0)
        self.perform(#selector(self.loadProfilePhoto), with: nil, afterDelay: 0.5)
        self.perform(#selector(self.getData), with: nil, afterDelay: 0.5)
        MainTabbarController.sharedMain.getNewNotifications()
        self.perform(#selector(self.hideProgressDialog), with: nil, afterDelay: 30)
    }
    
    @objc func loadProfilePhoto() {
        
        if let url = UserDefaults.standard.getUserPhotoUrl() {
            self.fetchImageDataAtURL(url, forButton: userPhoto)
        }
    }
    
    @objc func displayDate() {
        
        self.lbDate.text = self.getDateString()
        self.lbDate.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickedPhoto(_ sender:UIButton) {
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "myprofile") as! MyProfileViewController
        self.navigationController?.pushViewController(VC, animated: true)
    }

}

extension FollowingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (Bundle.main.loadNibNamed("FreshViewCell", owner: self, options: nil)![0]) as! FreshViewCell
        
        let feed = self.arrData[indexPath.row]
        
        let username = feed["username"] as! String
        cell.btnUsername.setTitle(username, for: UIControlState.normal)
        
        let songTitle = feed["songtitle"] as! String
        cell.lbSongtitle.text = songTitle
        
        let thumbnailurl = feed["thumbnail_url"] as! String
        self.fetchImageDataAtURL(thumbnailurl, forImageView: cell.imgThumbnail)
        
        let videourl = feed["video_url"] as! String
        cell.urlVideo = videourl
        
        if feed["upvotes"] == nil {
            cell.lbUpvotes.text = "0"
        }
        else {
            let upvotes = feed["upvotes"] as! Dictionary<String, AnyObject>
            cell.upVotesCount = upvotes.count
            cell.lbUpvotes.text = "\(String(describing: upvotes.count))"
        }
        
        let _userId = feed["userid"] as! String
        cell.userId = _userId
        let _feedId = feed["id"] as! String
        cell.feedId = _feedId
        cell.parentVC = self
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension FollowingViewController:FeedDelegate {
    
    func reloadData(_ cell: UITableViewCell) {
        
        self.perform(#selector(self.getData), with: nil, afterDelay: 0.5)
    }
}
