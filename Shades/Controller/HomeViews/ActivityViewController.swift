//
//  ActivityViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ActivityViewController: UIViewController {
    
    @IBOutlet var tblList:UITableView!
    @IBOutlet var userPhoto:UIButton!
    @IBOutlet var lbDate:UILabel!
    
    var arrData:[Dictionary<String, String>] = []
    
    var feedRefH:DatabaseHandle! = nil
    var feedRef: DatabaseReference!
    
    var userRefH:DatabaseHandle! = nil
    var userRef: DatabaseReference!
    
    var arrFollowing:[Dictionary<String, String>] = []
    
    var newCount = 0
    
    static var sharedNoti:ActivityViewController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        userPhoto.layer.cornerRadius = userPhoto.frame.size.width/2
        userPhoto.layer.masksToBounds = true
        ActivityViewController.sharedNoti = self
    }
    
    @objc func getData() {
        
        let checkConnection = RKCommon.checkInternetConnection()
        if !checkConnection {
            self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
            return
        }
        
        self.arrData.removeAll()
 
        let userid = UserDefaults.standard.getUserId()

        self.newCount = 0
        self.feedRef = Database.database().reference().child("notifications")
        self.feedRef.queryOrdered(byChild: "myid").queryEqual(toValue: userid).queryLimited(toLast: 50).observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                let feedData = (snap as! DataSnapshot).value as! Dictionary<String, String>
                let checked = feedData["checked"]
                if checked == "0" {
                    self.newCount += 1
                }
                self.arrData.insert(feedData, at: 0)
            }
            DispatchQueue.main.async(execute: {
                self.tblList.reloadData()
            })
        })
        
        self.arrFollowing.removeAll()
        userRef = Database.database().reference().child("users")
        userRef.queryOrdered(byChild: "userId").queryEqual(toValue: userid).observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                let userInfo = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                if userInfo["following"]  != nil {
                    
                    let arrDic = userInfo["following"] as! Dictionary<String, AnyObject>
                    for (_, element) in arrDic {
                        let follow = element as! Dictionary<String, String>
                        self.arrFollowing.append(follow)
                    }
                }
                DispatchQueue.main.async(execute: {
                    self.tblList.reloadData()
                })
                break
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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

extension ActivityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let feed = self.arrData[indexPath.row]
        
        let type = feed["type"]
        
        if type == "upvote" {
            let cell = (Bundle.main.loadNibNamed("ActivityViewCell", owner: self, options: nil)![0]) as! ActivityViewCell
            
            let username = feed["username"]
            cell.lbUsername.text = username
            
            cell.selNoti = feed
            cell.nIdx = indexPath.row
            
            let photourl = feed["userphoto"]
            self.fetchImageDataAtURL(photourl, forImageView: cell.imgUserPhoto)
            
            let time = feed["create_date"]
            cell.lbDate.text = getTimesAgo(time!)
            
            return cell
        }
        else {
            let cell = (Bundle.main.loadNibNamed("NotificationViewCell", owner: self, options: nil)![0]) as! NotificationViewCell
            
            let username = feed["username"]
            cell.lbUsername.text = username
            
            let photourl = feed["userphoto"]
            self.fetchImageDataAtURL(photourl, forImageView: cell.imgUserPhoto)
            
            let userid = feed["userid"]
            
            cell.userId = userid!
            cell.userName = username!
            cell.photoUrl = photourl!
            
            var bExist = false
            for item in self.arrFollowing {
                let uid = item["userId"]
                
                if uid == userid {
                    bExist = true
                    break
                }
            }
            
            cell.bFollowed = bExist
            cell.bFollowed = true
            cell.selNoti = feed
            cell.nIdx = indexPath.row
            
            let time = feed["create_date"]
            cell.lbDate.text = getTimesAgo(time!)
            
            return cell
        }
        
    }
    
    func getTimesAgo(_ dateString:String) -> String {
        
        let curDatetime = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdDate = dateFormatter.date(from: dateString)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day]
        formatter.unitsStyle = .full
        let diff = formatter.string(from: createdDate!, to: curDatetime)!
        //2 days, 3 hours, 25 minutes
        
        var ago = "1m"
        
        let arr = diff.split(separator: ",")
        if arr.count == 3 {
            var days:String = "\(arr[0])"
            days = days.replacingOccurrences(of: "days", with: "")
            days = days.replacingOccurrences(of: " ", with: "")
            days = "\(days)d"
            ago = days
        }
        else if arr.count == 2 {
            var hrs:String = "\(arr[0])"
            if hrs.contains("days") {
                hrs = hrs.replacingOccurrences(of: "days", with: "")
                hrs = hrs.replacingOccurrences(of: " ", with: "")
                hrs = "\(hrs)d"
                ago = hrs
            }
            else {
                hrs = hrs.replacingOccurrences(of: "hours", with: "")
                hrs = hrs.replacingOccurrences(of: " ", with: "")
                hrs = "\(hrs)h"
                ago = hrs
            }
        }
        else if arr.count == 1 {
            var mins:String = "\(arr[0])"
            if mins.contains("hours") {
                mins = mins.replacingOccurrences(of: "hours", with: "")
                mins = mins.replacingOccurrences(of: " ", with: "")
                mins = "\(mins)h"
                ago = mins
            }
            else {
                mins = mins.replacingOccurrences(of: "minutes", with: "")
                mins = mins.replacingOccurrences(of: " ", with: "")
                mins = "\(mins)m"
                ago = mins
            }
        }
        else {
            ago = "1m"
        }

        return ago
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.arrData[indexPath.row]
        let uid = item["userid"]!
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "friendprofile") as! FriendProfileViewController
        VC.userId = uid
        self.navigationController?.pushViewController(VC, animated: true)
    }
}
