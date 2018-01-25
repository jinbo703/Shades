//
//  FriendFollowCell.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

public protocol FollowDelegate : NSObjectProtocol {
    
    func reloadData(_ cell: UITableViewCell)
}

class FriendFollowCell: UITableViewCell {
    
    @IBOutlet var imgUserPhoto:UIImageView!
    @IBOutlet var lbUsername:UILabel!
    @IBOutlet var btnFollow:UIButton!
    @IBOutlet var btnUsername: UIButton!
    
    var delegate:FollowDelegate!
    let colorFollow = UIColor(red: 95/255.0, green: 141/255.0, blue: 255/255.0, alpha: 1.0)
    let colorUnfollow = UIColor(red: 255/255.0, green: 95/255.0, blue: 168/255.0, alpha: 1.0)
    
    var selUser:Dictionary<String, String>! = nil
    var bFollow = false
    var userRefH:DatabaseHandle! = nil
    var parentVC:UIViewController!
    
    var profileUserId: String? = nil
    
    var userInfo:Dictionary<String, AnyObject>! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgUserPhoto.layer.cornerRadius = imgUserPhoto.frame.size.width/2
        imgUserPhoto.layer.masksToBounds = true
        
        self.perform(#selector(self.getFollowState), with: nil, afterDelay: 0.5)
    }
    
    @objc func getFollowState() {
        
        if self.selUser == nil {
            return
        }
        let userId = self.selUser["userId"]! as String
        
        let userRef = Database.database().reference().child("users")
        userRef.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                
                self.userInfo = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                
                if self.userInfo["followers"]  != nil {
                    
                    var arrFollowers:[Dictionary<String, String>] = []
                    
                    let arr = self.userInfo["followers"] as! Dictionary<String, AnyObject>
                    for (_, element) in arr {
                        let follower = element as! Dictionary<String, String>
                        arrFollowers.append(follower)
                    }

                    let myusername = UserDefaults.standard.getUsername()
                    self.bFollow = false
                    for item in arrFollowers {
                        let uname = item["userName"]
                        if uname == myusername {
                            self.bFollow = true
                            break
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        if self.bFollow == true {
                            self.btnFollow.backgroundColor = self.colorUnfollow
                            self.btnFollow.setTitle("Unfollow", for: UIControlState.normal)
                            self.btnFollow.setNeedsDisplay()
                            self.bFollow = true
                        }
                        else {
                            self.btnFollow.backgroundColor = self.colorFollow
                            self.btnFollow.setTitle("Follow", for: UIControlState.normal)
                            self.btnFollow.setNeedsDisplay()
                            self.bFollow = false
                        }
                    })
                }
            }
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickedFollow(_ sender: UIButton) {
        if self.selUser == nil {
            return
        }
        let myId = UserDefaults.standard.getUserId();
        
        if self.profileUserId != myId {
            return
        }
        
        if self.bFollow == true {
            self.perform(#selector(unFollowUser), with: nil, afterDelay: 0.5)
        } else {
            self.perform(#selector(followUser), with: nil, afterDelay: 0.5)
        }
        
    }
    
    @objc func followUser() {
        let userRef = Database.database().reference().child("users")
        let followItem = [
            "userId": UserDefaults.standard.getUserId(),
            "userName": UserDefaults.standard.getUsername(),
            "photoUrl": UserDefaults.standard.getUserPhotoUrl(),
            ]
        let userId = self.userInfo["userId"]
        userRef.child(userId as! String).child("followers").child(UserDefaults.standard.getUserId()!).setValue(followItem);
        let followingItem = [
            "userId": self.userInfo["userId"],
            "userName": self.userInfo["userName"],
            "photoUrl": self.userInfo["photoUrl"],
            ]
        userRef.child(UserDefaults.standard.getUserId()!).child("following").child(userId as! String).setValue(followingItem);
        
        self.bFollow = true
        self.btnFollow.backgroundColor = self.colorUnfollow
        self.btnFollow.setTitle("Unfollow", for: UIControlState.normal)
        self.btnFollow.setNeedsDisplay()
    }
    
    @objc func unFollowUser() {
        let userRef = Database.database().reference().child("users")
        let userId = self.userInfo["userId"];
        userRef.child(userId as! String).child("followers").child(UserDefaults.standard.getUserId()!).setValue(nil);
        userRef.child(UserDefaults.standard.getUserId()!).child("following").child(userId as! String).setValue(nil);
        
        self.btnFollow.backgroundColor = self.colorFollow
        self.btnFollow.setTitle("Follow", for: UIControlState.normal)
        self.btnFollow.setNeedsDisplay()
        self.bFollow = false
    }
    @IBAction func onClickedUserName(_ sender: Any) {
        let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "friendprofile") as! FriendProfileViewController
        VC.userId = self.selUser["userId"]
        self.parentVC.navigationController?.pushViewController(VC, animated: true)
    }
}
