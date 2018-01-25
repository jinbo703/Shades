//
//  MyProfileViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import SVProgressHUD
import MobileCoreServices
import Firebase

class MyProfileViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var tblList:UITableView!
    @IBOutlet var userPhoto:UIImageView!
    @IBOutlet var lbDate:UILabel!
    @IBOutlet var lbUpvotes:UILabel!
    @IBOutlet var lbName: UILabel!
    @IBOutlet var lbSpots:UILabel!
    @IBOutlet var btnFollowers:UIButton!
    @IBOutlet var btnFollowing:UIButton!
    @IBOutlet var btnLogOut: UIButton!
    
    var userImage:UIImage! = nil
    
    var arrData:[Dictionary<String, AnyObject>] = []
    var userInfo:Dictionary<String, AnyObject>! = nil
    var userId:String! = UserDefaults.standard.getUserId()
    var arrFollowers:[Dictionary<String, String>] = []
    var arrFollowing:[Dictionary<String, String>] = []
    
    var storageRef: StorageReference = Storage.storage().reference(forURL: FIREBASE_APP_URL)

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
        
        if let url = UserDefaults.standard.getUserPhotoUrl() {
            self.fetchImageDataAtURL(url, forImageView: userPhoto)
        }
        
        let userid = UserDefaults.standard.getUserId()
        userRef = Database.database().reference().child("users")
        userRef.queryOrdered(byChild: "userId").queryEqual(toValue: userid).observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                
                self.userInfo = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                
                DispatchQueue.main.async(execute: {
                    
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
                    
                    if self.userInfo["userName"] != nil {
                        let userName:String = self.userInfo["userName"] as! String
                        self.lbName.text = "@\(userName)"
                    }
                })
                break
            }
            
        })
        
        self.arrData.removeAll()
        feedRef = Database.database().reference().child("feeds")
        feedRef.queryOrdered(byChild: "userid").queryEqual(toValue: userid).observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            
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
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MainTabbarController.sharedMain.getNewNotifications()
        self.loadData()
        self.perform(#selector(self.hideProgressDialog), with: nil, afterDelay: 30)
    }
    
    @IBAction func onClickedLogOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            
            UserDefaults.standard.setIsLoggedIn(value: false)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "initialView")
            self.present(controller, animated: true, completion: nil)
            
        } catch (let error) {
            print((error as NSError).code)
        }
    }
    
    @IBAction func onClickedSupport(_ sender: Any) {
        self.showJHTAlerttOkayWithIcon(message: "For support: support@shadesware.com")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickedPhoto(_ sender:UIButton) {

        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let takeAction = UIAlertAction(title: "Take Photo",
                                       style: .default, handler: { (action) -> Void in
                                        
                                        DispatchQueue.main.async(execute: {
                                            let pickerImageVC = UIImagePickerController()
                                            pickerImageVC.delegate = self
                                            pickerImageVC.allowsEditing = true
                                            pickerImageVC.sourceType = .camera
                                            self.present(pickerImageVC, animated: false, completion: nil)
                                        })
        })
        alert.addAction(takeAction)
        
        let libraryAction = UIAlertAction(title: "Select from library",
                                       style: .default, handler: { (action) -> Void in

                                        DispatchQueue.main.async(execute: {
                                            let pickerImageVC = UIImagePickerController()
                                            pickerImageVC.delegate = self
                                            pickerImageVC.allowsEditing = true
                                            pickerImageVC.sourceType = .photoLibrary
                                            self.present(pickerImageVC, animated: false, completion: nil)
                                        })
        })
        alert.addAction(libraryAction)
        self.present(alert, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: false, completion: nil)
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.userPhoto.image = image
        self.userImage = image
        
        SVProgressHUD.show()
        self.perform(#selector(uploadUserPhoto), with: nil, afterDelay: 0.5)
    }
    
    @objc func uploadUserPhoto() {
        
        if self.userImage == nil {
            return
        }
        
        let dataPhoto = UIImagePNGRepresentation(self.userImage!)
        
        SVProgressHUD.show()
        let userid:String = UserDefaults.standard.getUserId()!
        let path = "Profile_Photos/\(String(describing: userid))_\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        
        self.storageRef.child(path).putData(dataPhoto!, metadata: nil) { (metadata, error) in
            if let error = error {
                self.showJHTAlerttOkayWithIcon(message:error.localizedDescription)
                SVProgressHUD.dismiss()
                return
            }
            
            let url = self.storageRef.child((metadata?.path)!).description
            self.updateUserInfo(url)
        }
    }
    
    @objc func updateUserInfo(_ url: String?) {
        
        UserDefaults.standard.setUserPhotoUrl(url!)
        UserDefaults.standard.synchronize()
        
        let uid = UserDefaults.standard.getUserId()
        let ref = Database.database().reference()
        let userReference = ref.child("users").child(uid!)
        
        let username = UserDefaults.standard.getUsername()
        let email = UserDefaults.standard.getEmail()
        let fullName = UserDefaults.standard.getFullname()
        let firstname = UserDefaults.standard.getFirstname()
        let lastname = UserDefaults.standard.getLastname()
        let birthday = UserDefaults.standard.getBirthday()
        let memberSinceString = UserDefaults.standard.getUserCreatedDate()
        
        let values = ["userId": uid, "userName": username, "email": email, "firstName": firstname, "lastName": lastname, "birthday": birthday, "memberSince": memberSinceString, "fullName": fullName, "photoUrl": url]
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                SVProgressHUD.dismiss()
                self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later")
                return
            }
            
            self.showJHTAlerttOkayWithIcon(message: "Successfully uploaded!")
            SVProgressHUD.dismiss()
        })
    }
    
    
    @IBAction func onClickedBack(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
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
    
}

extension MyProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
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


extension MyProfileViewController:FeedDelegate {
    
    func reloadData(_ cell: UITableViewCell) {
        
        self.perform(#selector(self.loadData), with: nil, afterDelay: 0.5)
    }
}

