//
//  MainTabbarController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MainTabbarController: UITabBarController, UITabBarControllerDelegate {
    
    static var sharedMain:MainTabbarController!
    
    var newNotiCount = 0
    
    var feedRefH:DatabaseHandle! = nil
    var feedRef: DatabaseReference!
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                AnimationVC.popView(self, toRight: false)
                MainTabbarController.sharedHome = nil
                break
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                break
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                break
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
                break
            default:
                break
            }
        }
    }
    
    
    static var sharedHome:MainTabbarController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        MainTabbarController.sharedHome = self
        
        self.selectedIndex = 0
        self.delegate = self
        
        MainTabbarController.sharedMain = self
        
       self.tabBar.items![3].badgeValue = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let refHandle = self.feedRefH {
            self.feedRef.removeObserver(withHandle: refHandle)
        }
    }
    
    @objc func getNewNotifications() {
        let checkConnection = RKCommon.checkInternetConnection()
        if !checkConnection {
            return
        }
        
        let userid = UserDefaults.standard.getUserId()
        self.newNotiCount = 0
        self.feedRef = Database.database().reference().child("notifications")
        self.feedRef.queryOrdered(byChild: "myid").queryEqual(toValue: userid).queryLimited(toLast: 50).observeSingleEvent(of: .value, with:{ (snapshot: DataSnapshot) in
            self.newNotiCount = 0
            for snap in snapshot.children {
                let notiData = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                let timestamp = notiData["create_date"] as! String
                if self.checkOldItem(timestamp) == true {
                    let id = notiData["id"] as! String
                    let notiRef = Database.database().reference().child("notifications")
                    notiRef.child(id).setValue(nil)
                }
                else {
                    let checked = notiData["checked"] as! String
                    if checked == "0" {
                        self.newNotiCount += 1
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                if self.newNotiCount > 0 {
                    self.tabBar.items![3].badgeValue = "\(self.newNotiCount)"
                }
                else {
                    self.tabBar.items![3].badgeValue = nil
                }
            })
        })
    }
    
    func checkOldItem(_ dateString:String) -> Bool {
        
        let curDatetime = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdDate = dateFormatter.date(from: dateString)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        let diff = formatter.string(from: createdDate!, to: curDatetime)!
        
        let arr = diff.split(separator: " ")
        if arr.count == 2 {
            let days = Int(arr[0])!
            if days >= 7 {
                return true
            }
        }
        
        return false
    }
    
    static func sharedInstance() -> MainTabbarController {
        
        return MainTabbarController.sharedMain
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        
    }
    
}
