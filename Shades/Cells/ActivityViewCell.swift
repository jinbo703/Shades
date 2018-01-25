//
//  ActivityViewCell.swift
//  Shades
//
//  Created by MacAdmin on 23/11/2017.
//  Copyright © 2017 Sergei Dudka. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ActivityViewCell: UITableViewCell {

    @IBOutlet var imgUserPhoto:UIImageView!
    @IBOutlet var lbUsername:UILabel!
    @IBOutlet var lbDesc:UILabel!
    @IBOutlet var lbDate:UILabel!

    var selNoti:Dictionary<String, String>! = nil
    var nIdx = 0
    
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
