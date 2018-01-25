//
//  NotificationViewCell.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class NotificationViewCell: UITableViewCell {

    @IBOutlet var imgUserPhoto:UIImageView!
    @IBOutlet var lbUsername:UILabel!
    @IBOutlet var lbDesc:UILabel!
    @IBOutlet var lbDate:UILabel!
    @IBOutlet var btnFollow:UIButton!
        
    var selNoti:Dictionary<String, String>! = nil
    var bFollowed = false
    var nIdx = 0
    var userId:String? = nil
    var userName:String? = nil
    var photoUrl:String? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgUserPhoto.layer.cornerRadius = imgUserPhoto.frame.size.width/2
        imgUserPhoto.layer.masksToBounds = true
        
        self.perform(#selector(checkNotification), with: nil, afterDelay: 0.5)
    }
    
    @objc func checkNotification() {
        
        if self.selNoti == nil {
            return
        }
        let checked = self.selNoti["checked"]
        if checked == "0" {
            let id = self.selNoti["id"]
            let notiRef = Database.database().reference().child("notifications")
            notiRef.child(id!).child("checked").setValue("1")
            
            if MainTabbarController.sharedMain.newNotiCount > 0 {
                MainTabbarController.sharedMain.newNotiCount -= 1
            }
            let count = MainTabbarController.sharedMain.newNotiCount
            if count > 0 {
                MainTabbarController.sharedMain.tabBar.items![3].badgeValue = "\(count)"
            }
            else {
                MainTabbarController.sharedMain.tabBar.items![3].badgeValue = nil
            }
            self.selNoti["checked"] = "1"
            ActivityViewController.sharedNoti.arrData[self.nIdx] = self.selNoti
        }
        
        if bFollowed == true {
            btnFollow.setBackgroundImage(UIImage(named:"un_follow"), for: UIControlState.normal)
        }
        else {
            btnFollow.setBackgroundImage(UIImage(named:"add_follow"), for: UIControlState.normal)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickedFollow(_ sender: UIButton) {
        
        if self.selNoti == nil {
            return
        }
        if self.bFollowed == true {
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
        userRef.child(self.userId!).child("followers").child(UserDefaults.standard.getUserId()!).setValue(followItem);
        let followingItem = [
            "userId": userId,
            "userName": userName,
            "photoUrl": photoUrl,
            ]
        userRef.child(UserDefaults.standard.getUserId()!).child("following").child(self.userId!).setValue(followingItem);
        
        self.bFollowed = true
        btnFollow.setBackgroundImage(UIImage(named:"un_follow"), for: UIControlState.normal)
    }
    
    @objc func unFollowUser() {
        let userRef = Database.database().reference().child("users")
        userRef.child(self.userId!).child("followers").child(UserDefaults.standard.getUserId()!).setValue(nil);
        userRef.child(UserDefaults.standard.getUserId()!).child("following").child(self.userId!).setValue(nil);
        
        self.bFollowed = false
        btnFollow.setBackgroundImage(UIImage(named:"add_follow"), for: UIControlState.normal)
    }
}
