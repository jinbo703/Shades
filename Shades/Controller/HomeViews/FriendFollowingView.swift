//
//  FriendFollowingView.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//s

import UIKit
import Firebase
import SVProgressHUD

class FriendFollowingView: UIViewController {
    
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var tblList:UITableView!
    
    var arrSearch:[Dictionary<String, String>] = []
    
    var userInfo:Dictionary<String, AnyObject>! = nil
    var userId:String! = nil
    var arrFollowing:[Dictionary<String, String>] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for item in self.arrFollowing {
            self.arrSearch.append(item)
        }
        self.tblList.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MainTabbarController.sharedMain.getNewNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickedBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension FriendFollowingView: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.arrSearch.removeAll()
        for item in self.arrFollowing {
            self.arrSearch.append(item)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.arrSearch.removeAll()
        let key = searchBar.text?.lowercased()
        for item in self.arrFollowing {
            var uname = item["userName"]!
            uname = uname.lowercased()
            if uname.contains(key!) == true {
                self.arrSearch.append(item)
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
}

extension FriendFollowingView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (Bundle.main.loadNibNamed("FriendFollowCell", owner: self, options: nil)![0]) as! FriendFollowCell
        
        let item = self.arrSearch[indexPath.row]
        let username = item["userName"]
        cell.lbUsername.text = username
        
        let myuname = UserDefaults.standard.getUsername()
        if username == myuname {
            cell.btnFollow.isHidden = true
        }
        
        let photoUrl = item["photoUrl"]
        self.fetchImageDataAtURL(photoUrl, forImageView: cell.imgUserPhoto)
        
        cell.profileUserId = self.userId
        cell.selUser = item
        cell.delegate = self
        cell.parentVC = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension FriendFollowingView:FollowDelegate {
    
    func reloadData(_ cell: UITableViewCell) {
        
        
    }
}


