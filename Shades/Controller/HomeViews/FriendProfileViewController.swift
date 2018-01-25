//
//  FriendProfileViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//s

import UIKit
import Firebase
import SVProgressHUD

class FriendProfileViewController: UIViewController {
    
    @IBOutlet var tblList:UITableView!
    @IBOutlet var userPhoto:UIImageView!
    @IBOutlet var lbDate:UILabel!
    @IBOutlet var lbUpvotes:UILabel!
    @IBOutlet var lbSpots:UILabel!
    @IBOutlet var btnFollowers:UIButton!
    @IBOutlet var btnFollowing:UIButton!
    @IBOutlet var btnFollow:UIButton!
    @IBOutlet var lbUsername:UILabel!
    @IBOutlet var btnBlock: UIButton!
    
    let colorFollow = UIColor(red: 95/255.0, green: 141/255.0, blue: 255/255.0, alpha: 1.0)
    let colorUnfollow = UIColor(red: 255/255.0, green: 95/255.0, blue: 168/255.0, alpha: 1.0)
    
    var bFollow:Bool = false
    var bBlock:Bool = false
    
    var arrData:[Dictionary<String, AnyObject>] = []
    var userInfo:Dictionary<String, AnyObject>! = nil
    var userId:String! = nil
    var arrFollowers:[Dictionary<String, String>] = []
    var arrFollowing:[Dictionary<String, String>] = []
    
    var userRefH:DatabaseHandle! = nil
    var userRef: DatabaseReference!
    
    var feedRefH:DatabaseHandle! = nil
    var feedRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        userPhoto.layer.cornerRadius = userPhoto.frame.size.width/2
        userPhoto.layer.masksToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func loadData() {
        
        if self.userId == nil {
            return
        }
        
        SVProgressHUD.show()
        userRef = Database.database().reference().child("users")
        userRef.queryOrdered(byChild: "userId").queryEqual(toValue: self.userId).observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                
                self.userInfo = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                
                DispatchQueue.main.async(execute: {
                    
                    let username = self.userInfo["userName"] as! String
                    var photoUrl = ""
                    if self.userInfo["photoUrl"] != nil {
                        photoUrl = self.userInfo["photoUrl"] as! String
                    }
                    
                    self.fetchImageDataAtURL(photoUrl, forImageView: self.userPhoto)
                    self.lbUsername.text = username
                    
                    if self.userInfo["followers"]  == nil {
                        self.btnFollowers.setTitle("0", for: UIControlState.normal)
                    }
                    else {
                        self.arrFollowers.removeAll()
                        
                        let arr = self.userInfo["followers"] as! Dictionary<String, AnyObject>
                        for (_, element) in arr {
                            let follower = element as! Dictionary<String, String>
                            self.arrFollowers.append(follower)
                        }

                        let nCount = self.arrFollowers.count
                        self.btnFollowers.setTitle("\(nCount)", for: UIControlState.normal)
                        
                        let myusername = UserDefaults.standard.getUsername()
                        var bFollowing = false
                        for item in self.arrFollowers {
                            let uname = item["userName"]
                            if uname == myusername {
                                bFollowing = true
                                break
                            }
                        }
                        if bFollowing == true {
                            self.btnFollow.backgroundColor = self.colorUnfollow
                            self.btnFollow.setTitle("Unfollow", for: UIControlState.normal)
                            self.bFollow = true
                        }
                        else {
                            self.btnFollow.backgroundColor = self.colorFollow
                            self.btnFollow.setTitle("Follow", for: UIControlState.normal)
                            self.bFollow = false
                        }
                    }
                    
                    if self.userInfo["following"]  == nil {
                        self.btnFollowing.setTitle("0", for: UIControlState.normal)
                    }
                    else {
                        self.arrFollowing.removeAll()

                        let arr = self.userInfo["following"] as! Dictionary<String, AnyObject>
                        for (_, element) in arr {
                            let follower = element as! Dictionary<String, String>
                            self.arrFollowing.append(follower)
                        }
                        
                        let nCount = self.arrFollowing.count
                        self.btnFollowing.setTitle("\(nCount)", for: UIControlState.normal)
                    }
                    
                    if self.userInfo["upvoteCount"] == nil {
                        self.lbUpvotes.text = "0"
                    }
                    else {
                        let upvotes = self.userInfo["upvoteCount"] as! String
                        self.lbUpvotes.text = upvotes
                    }
                    
                    if self.userInfo["spotCount"] == nil {
                        self.lbSpots.text = "0"
                    }
                    else {
                        let spots = self.userInfo["spotCount"] as! String
                        self.lbSpots.text = spots
                    }
                    
                    SVProgressHUD.dismiss()
                })
                break
            }
        })
        
        self.arrData.removeAll()
        SVProgressHUD.show()
        feedRef = Database.database().reference().child("feeds")
        feedRef.queryOrdered(byChild: "userid").queryEqual(toValue: self.userId).observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                let feedData = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                let createdTime = feedData["create_date"] as! String
                if MainTabbarController.sharedMain.checkOldItem(createdTime) == true {
                    let id = feedData["id"] as! String
                    Database.database().reference().child("feeds").child(id).setValue(nil)
                }
                else {
                    self.arrData.insert(feedData, at: 0)
                }
            }
            DispatchQueue.main.async(execute: {
                self.tblList.reloadData()
                SVProgressHUD.dismiss()
            })
        })
        
        bBlock = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MainTabbarController.sharedMain.getNewNotifications()
        self.perform(#selector(self.loadData), with: nil, afterDelay: 0.5)
        self.perform(#selector(self.hideProgressDialog), with: nil, afterDelay: 30)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickedBack(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickedFollow(_ sender:UIButton) {
        
        if bFollow == false {
            btnFollow.backgroundColor = colorUnfollow
            btnFollow.setTitle("Unfollow", for: UIControlState.normal)
            let count = Int(btnFollowers.currentTitle!)
            btnFollowers.setTitle("\(count!+1)", for: UIControlState.normal)
            bFollow = true
            self.perform(#selector(followUser), with: nil, afterDelay: 0.5)
        }
        else {
            btnFollow.backgroundColor = colorFollow
            btnFollow.setTitle("Follow", for: UIControlState.normal)
            let count = Int(btnFollowers.currentTitle!)
            btnFollowers.setTitle("\(count!-1)", for: UIControlState.normal)
            bFollow = false
            self.perform(#selector(unfollowUser), with: nil, afterDelay: 0.5)
        }
    }
    
    @IBAction func onClickedBlock(_ sender: Any) {
        if bBlock == false {
            btnBlock.backgroundColor = colorUnfollow
            btnBlock.setTitle("UnBlock", for: UIControlState.normal)
            bBlock = true
            self.perform(#selector(blockUser), with: nil, afterDelay: 0.5)
        } else {
            btnBlock.backgroundColor = colorFollow
            btnBlock.setTitle("Block", for: UIControlState.normal)
            bBlock = false
            self.perform(#selector(unBlockUser), with: nil, afterDelay: 0.5)
        }
    }
    
    @IBAction func onClickedFollowers(_ sender:UIButton) {
        
        let count = self.btnFollowers.currentTitle as String?
        if Int(count!) == 0 {
            return
        }
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "friendfollowers") as! FriendFollowersView
        VC.userId = self.userId
        VC.userInfo = self.userInfo
        VC.arrFollowers = self.arrFollowers
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func onClickedFollowing(_ sender:UIButton) {
        
        let count = self.btnFollowing.currentTitle as String?
        if Int(count!) == 0 {
            return
        }
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "friendfollowing") as! FriendFollowingView
        VC.userId = self.userId
        VC.userInfo = self.userInfo
        VC.arrFollowing = self.arrFollowing
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc func blockUser() {
        userRef = Database.database().reference().child("users")
        let blockItem = [
            "userId": self.userInfo["userId"],
            "userName": self.userInfo["userName"],
            ]
        userRef.child(UserDefaults.standard.getUserId()!).child("blocks").child(self.userId).setValue(blockItem);
    }
    
    @objc func unBlockUser() {
        userRef.child(UserDefaults.standard.getUserId()!).child("blocks").child(self.userId).setValue(nil);
    }
    
    @objc func followUser() {
        userRef = Database.database().reference().child("users")
        let followItem = [
            "userId": UserDefaults.standard.getUserId(),
            "userName": UserDefaults.standard.getUsername(),
            "photoUrl": UserDefaults.standard.getUserPhotoUrl(),
        ]
        userRef.child(self.userId).child("followers").child(UserDefaults.standard.getUserId()!).setValue(followItem);
        let followingItem = [
            "userId": self.userInfo["userId"],
            "userName": self.userInfo["userName"],
            "photoUrl": self.userInfo["photoUrl"],
        ]
        userRef.child(UserDefaults.standard.getUserId()!).child("following").child(self.userId).setValue(followingItem);
        
        let id = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createtime = dateFormatter.string(from: NSDate() as Date)
        
        let notificationItem = [
            "id": "\(id)",
            "myid": self.userId,
            "create_date": createtime,
            "userid": UserDefaults.standard.getUserId(),
            "username": UserDefaults.standard.getUsername(),
            "userphoto": UserDefaults.standard.getUserPhotoUrl(),
            "type": "follow",
            "checked": "0"
        ]
        
        self.userRef = Database.database().reference().child("notifications")
        self.userRef.child("\(id)").setValue(notificationItem)
        
        loadData()
    }
    
    @objc func unfollowUser() {
        userRef = Database.database().reference().child("users")
        userRef.child(self.userId).child("followers").child(UserDefaults.standard.getUserId()!).setValue(nil);
        userRef.child(UserDefaults.standard.getUserId()!).child("following").child(self.userId).setValue(nil);
        
        loadData()
    }
}

extension FriendProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
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

extension FriendProfileViewController:FeedDelegate {
    
    func reloadData(_ cell: UITableViewCell) {
        
        self.perform(#selector(self.loadData), with: nil, afterDelay: 0.5)
    }
}

