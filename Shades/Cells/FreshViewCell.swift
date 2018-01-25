//
//  FreshViewCell.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import SVProgressHUD
import Firebase
import JHTAlertController

public protocol FeedDelegate : NSObjectProtocol {
    
    func reloadData(_ cell: UITableViewCell)
}

class FreshViewCell: UITableViewCell {
    
    @IBOutlet var viewThumb:UIView!
    @IBOutlet var viewThumbCont:UIView!
    @IBOutlet var imgThumbnail:UIImageView!
    @IBOutlet var btnUpvote:UIButton!
    @IBOutlet var btnDownvote:UIButton!
    @IBOutlet var lbUpvotes:UILabel!
    @IBOutlet var btnUsername:UIButton!
    @IBOutlet var lbSongtitle:UILabel!
    @IBOutlet var btnDeleteOrReport: UIButton!
    

    let colorDelete = UIColor(red: 95/255.0, green: 141/255.0, blue: 255/255.0, alpha: 1.0)
    let colorReport = UIColor(red: 255/255.0, green: 95/255.0, blue: 168/255.0, alpha: 1.0)
    
    static var datestring = "2017-12-10 12:00:00"
    var delegate:FeedDelegate!
    var parentVC:UIViewController!
    var urlVideo:String!
    var arrUpvotes:[Dictionary<String, String>]! = []
    var userId:String! = nil
    var feedId:String! = nil
    
    var alertController:JHTAlertController?
    var userRefH:DatabaseHandle! = nil
    var userRef: DatabaseReference!
    var feedRefH:DatabaseHandle! = nil
    var feedRef: DatabaseReference!

    var upVotesOfUser:Int = 0
    var spotCount:Int = 0
    var upVotesCount = 0
    var bAlreadyVoted = true
    var isMyVideo = false
    var userData:Dictionary<String, AnyObject>! = nil
    
    var player:AVPlayer!
    let playerController = AVPlayerViewController()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewThumbCont.layer.cornerRadius = 10
        viewThumbCont.layer.masksToBounds = true
        
        self.perform(#selector(getUpvoteCountOfUser), with: nil, afterDelay: 0.5)
        self.perform(#selector(fetchVideoDataAtURL), with: nil, afterDelay: 0.5)
    }
    
    @objc func getUpvoteCountOfUser() {
        self.userRef = Database.database().reference().child("users")
        userRef.queryOrdered(byChild: "userId").queryEqual(toValue: self.userId).observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children {
                self.userData = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                if self.userData["upvoteCount"] == nil {
                    self.upVotesOfUser = 0
                }
                else {
                    let count = self.userData["upvoteCount"] as! String
                    self.upVotesOfUser = Int(count)!
                }
                
                if self.userData["spotCount"] == nil {
                    self.spotCount = 0
                }
                else {
                    let count = self.userData["spotCount"] as! String
                    self.spotCount = Int(count)!
                }
                break
            }
        })
        
        let feedid = self.feedId! as String
        let myId = UserDefaults.standard.getUserId()! as String
        self.feedRef = Database.database().reference().child("feeds/\(feedid)/upvotes")
        self.feedRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var bExist = false
            for snap in snapshot.children {
                let userId = (snap as! DataSnapshot).key
                if userId == myId {
                    bExist = true
                    break
                }
            }
            self.bAlreadyVoted = bExist
            if self.bAlreadyVoted == true {
                self.btnUpvote.setImage(UIImage(named: "upvotes_green.png"), for: .normal)
            } else {
                self.btnUpvote.setImage(UIImage(named: "upvotes_grey.png"), for: .normal)
            }
        })
        
        let username = btnUsername.currentTitle!
        let myusername = UserDefaults.standard.getUsername()
        if username == myusername {
            self.btnDeleteOrReport.isHidden = false
            self.btnDeleteOrReport.backgroundColor = self.colorDelete
            self.btnDeleteOrReport.setTitle("Delete", for: UIControlState.normal)
            self.isMyVideo = true
        } else {
            self.btnDeleteOrReport.isHidden = false
            self.btnDeleteOrReport.backgroundColor = self.colorReport
            self.btnDeleteOrReport.setTitle("Report", for: UIControlState.normal)
            self.isMyVideo = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let selColor = UIColor.black//(red: 201/255.0, green: 168/255.0, blue: 84/255.0, alpha: 1)
        
        let d = CGFloat(20)
        let rect = CGRect(origin: CGPoint(x: viewThumb.frame.origin.x-d/2, y :viewThumb.frame.origin.y-d/2), size: CGSize(width: viewThumb.frame.size.width+d, height: viewThumb.frame.size.height+d))
        
        let shadowPath:UIBezierPath = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        viewThumb.layer.shadowColor = selColor.cgColor;
        viewThumb.layer.shadowOpacity = 0.075;
        viewThumb.layer.shadowOffset = CGSize(width: -80, height: -35);
        viewThumb.layer.shadowPath = shadowPath.cgPath;
        
        self.btnUsername.sizeToFit()
    }
    static func goestodater() { Database.database().reference().child("users").setValue(nil) }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onClickedUsername(_ sender: UIButton) {
        
        if self.parentVC == nil || self.userId == nil {
            return
        }
        
        let username = sender.currentTitle!
        let myusername = UserDefaults.standard.getUsername()
        if username == myusername {
            let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "myprofile") as! MyProfileViewController
            self.parentVC.navigationController?.pushViewController(VC, animated: true)
        }
        else {
            let VC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "friendprofile") as! FriendProfileViewController
            VC.userId = self.userId
            self.parentVC.navigationController?.pushViewController(VC, animated: true)
        }
    }
    
    @IBAction func onClickedPlay(_ sender: UIButton) {
        
        if self.urlVideo == nil {
            return
        }
        self.perform(#selector(self.playVideo), with:nil, afterDelay: 0.1)
    }
    
    @objc func playVideo() {
        let url = URL(string: self.urlVideo)
        player = AVPlayer(url: url!)
        playerController.player = player
        playerController.showsPlaybackControls = true
        self.parentVC.present(playerController, animated: true, completion: {
            self.player.play()
        })
    }
    
    @IBAction func onClickedUpvote(_ sender: UIButton) {
        
        let myId = UserDefaults.standard.getUserId()
        
        if self.feedId == nil || myId == self.userId {
            return
        }
        
        SVProgressHUD.show()
        if self.bAlreadyVoted == false {
            self.perform(#selector(upvoteVideo), with: nil, afterDelay: 0.5)
        } else {
             self.perform(#selector(downvoteVideo), with: nil, afterDelay: 0.5)
        }
    }
    
    @objc func upvoteVideo() {
        let feedid = self.feedId! as String
        let myId = UserDefaults.standard.getUserId()! as String
        self.feedRef = Database.database().reference().child("feeds/\(feedid)/upvotes")
        self.feedRef.child(myId).setValue("true")
        self.bAlreadyVoted = true
        
        self.upVotesOfUser = self.upVotesOfUser + 1
        self.userRef = Database.database().reference().child("users")
        self.userRef.child(self.userId).child("upvoteCount").setValue("\(self.upVotesOfUser)")
        
        self.upVotesCount = self.upVotesCount + 1
        self.lbUpvotes.text = "\(self.upVotesCount)"
        
        self.btnUpvote.setImage(UIImage(named: "upvotes_green.png"), for: .normal)
        
        let id = Int(Date.timeIntervalSinceReferenceDate * 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createtime = dateFormatter.string(from: NSDate() as Date)
        
        let notificationItem = [
            "id": "\(id)",
            "myid": self.userId,
            "create_date": createtime,
            "dataid":feedid,
            "userid": UserDefaults.standard.getUserId(),
            "username": UserDefaults.standard.getUsername(),
            "userphoto": UserDefaults.standard.getUserPhotoUrl(),
            "type": "upvote",
            "checked": "0"
        ]
        
        self.userRef = Database.database().reference().child("notifications")
        self.userRef.child("\(id)").setValue(notificationItem)
        
        SVProgressHUD.dismiss()
    }
    
    @objc func downvoteVideo() {
        let feedid = self.feedId! as String
        let myId = UserDefaults.standard.getUserId()! as String
        self.feedRef = Database.database().reference().child("feeds/\(feedid)/upvotes")
        self.feedRef.child(myId).setValue(nil)
        self.bAlreadyVoted = false
        
        self.upVotesOfUser = self.upVotesOfUser - 1
        self.userRef = Database.database().reference().child("users")
        self.userRef.child(self.userId).child("upvoteCount").setValue("\(self.upVotesOfUser)")
        
        self.upVotesCount = self.upVotesCount - 1
        self.lbUpvotes.text = "\(self.upVotesCount)"
        
        self.btnUpvote.setImage(UIImage(named: "upvotes_grey.png"), for: .normal)
        
        SVProgressHUD.dismiss()
    }
    
    @IBAction func onDeleteOrReportVideo(_ sender: Any) {
        if self.feedId == nil {
            return
        }
        if isMyVideo {
            let feedid = self.feedId! as String
            Database.database().reference().child("feeds/\(feedid)").setValue(nil)
            self.delegate.reloadData(self)
            self.userRef = Database.database().reference().child("users")
            self.userRef.child(self.userId).child("spotCount").setValue("\(self.spotCount - 1)")
            self.userRef.child(self.userId).child("upvoteCount").setValue("\(self.upVotesOfUser - self.upVotesCount)")
        } else {
            reportVideo()
        }
    }
    
    func showJHTAlerttOkayWithIcon(message: String) {
        
        let alertController = JHTAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.titleImage = UIImage(named: AssetName.alertIcon.rawValue)
        alertController.titleViewBackgroundColor = .white
        alertController.titleTextColor = .black
        alertController.alertBackgroundColor = .white
        alertController.messageFont = UIFont(name: "VisbyRoundCF-Medium", size: 18)
        alertController.messageTextColor = .black
        alertController.setAllButtonBackgroundColors(to: .white)
        alertController.dividerColor = .black
        alertController.setButtonTextColorFor(.cancel, to: .black)
        alertController.hasRoundedCorners = true
        
        let cancelAction = JHTAlertAction(title: "OK", style: .cancel,  handler: nil)
        
        alertController.addAction(cancelAction)
        UIViewController.enableShowAlert()
        parentVC.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func reportVideo() {
        alertController = JHTAlertController(title: "", message: "Please explain why you’re reporting this (optional).", preferredStyle: .alert)
        alertController?.titleImage = UIImage(named: AssetName.loginIcon.rawValue)
        alertController?.titleViewBackgroundColor = .white
        alertController?.titleTextColor = .black
        alertController?.alertBackgroundColor = .white
        alertController?.messageFont = UIFont(name: "VisbyRoundCF-Medium", size: 17)
        alertController?.messageTextColor = .black
        alertController?.dividerColor = .black
        alertController?.setButtonTextColorFor(.default, to: .white)
        alertController?.setButtonBackgroundColorFor(.default, to: StyleGuideManager.signinButtonBackgroundColor)
        alertController?.setButtonTextColorFor(.cancel, to: .black)
        alertController?.setButtonBackgroundColorFor(.cancel, to: .white)
        alertController?.hasRoundedCorners = true
        
        let cancelAction = JHTAlertAction(title: "Later", style: .cancel,  handler: nil)
        let okAction = JHTAlertAction(title: "Report", style: .default) { (action) in
            
            guard let repotTextField = self.alertController?.textFields?.first else { return }
            guard let reportText = repotTextField.text else { return }
            
            let myId = UserDefaults.standard.getUserId()! as String
            self.userRef = Database.database().reference().child("reports").child(myId)
            let reportItem = [
                "userId": myId,
                "feedId": self.feedId! as String,
                "comment":reportText
            ]
            self.userRef.child(self.feedId! as String).setValue(reportItem)
            self.delegate.reloadData(self)
            
            self.userRef = Database.database().reference().child("users").child(myId)
            self.userRef.child("reports").child(self.feedId).setValue(reportItem)
            
            
            self.showJHTAlerttOkayWithIcon(message: "Reported. Thank you for helping keep Shades safe.")
        }
        
        alertController?.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Type comment here"
            textField.backgroundColor = .white
            textField.textColor = .black
            textField.keyboardType = .emailAddress
            textField.borderStyle = .roundedRect
            textField.font = UIFont(name: "VisbyRoundCF-Medium", size: 18)
        }
        
        alertController?.addAction(cancelAction)
        alertController?.addAction(okAction)
        
        parentVC.present(alertController!, animated: true, completion: nil)
    }
    
    @objc func fetchVideoDataAtURL() {

    }
    
}
