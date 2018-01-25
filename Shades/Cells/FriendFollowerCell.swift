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

public protocol FollowerDelegate : NSObjectProtocol {
    
    func reloadData(_ cell: UITableViewCell)
}

class FriendFollowerCell: UITableViewCell {
    
    @IBOutlet var imgUserPhoto:UIImageView!
    @IBOutlet var lbUsername:UILabel!
    @IBOutlet var btnUserName: UIButton!
    
    var delegate:FollowerDelegate!

    var selUser:Dictionary<String, String>! = nil
    var bFollow = false
    var userRefH:DatabaseHandle! = nil
    var parentVC:UIViewController!
    
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
                
                if self.userInfo["following"]  != nil {
                    
                    var arrFollowers:[Dictionary<String, String>] = []
                    
                    let arr = self.userInfo["following"] as! Dictionary<String, AnyObject>
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
                }
            }
        })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func onClickedUserName(_ sender: Any) {
        let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "friendprofile") as! FriendProfileViewController
        VC.userId = self.selUser["userId"]
        self.parentVC.navigationController?.pushViewController(VC, animated: true)
    }
}
