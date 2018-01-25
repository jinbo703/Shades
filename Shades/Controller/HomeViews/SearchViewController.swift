//
//  SearchViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SearchViewController: UIViewController {
    
    var arrUsers:[Dictionary<String, AnyObject>] = []
    var arrSearch:[Dictionary<String, AnyObject>] = []
    
    @IBOutlet var tblList:UITableView!
    @IBOutlet var searchBar:UISearchBar!

    var userRefH:DatabaseHandle! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.isNavigationBarHidden = true
        
        MainTabbarController.sharedMain.getNewNotifications()
        self.perform(#selector(getAllUsers), with: nil, afterDelay: 0.5)
        self.perform(#selector(self.hideProgressDialog), with: nil, afterDelay: 30)
        
    }
    
    @objc func getAllUsers() {
        
        let checkConnection = RKCommon.checkInternetConnection()
        if !checkConnection {
            self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
            return
        }
        
        self.arrUsers.removeAll()
        self.arrSearch.removeAll()

        let userRef = Database.database().reference().child("users")
        
        let myId = UserDefaults.standard.getUserId()
        
        userRefH = userRef.queryOrdered(byChild: "userName").observe(.value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                let userData = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                let userId = userData["userId"] as! String
                if userData["userId"] == nil {
                    continue
                }
                if userId == myId {
                    continue
                }
                
                self.arrUsers.append(userData)
            }
            DispatchQueue.main.async(execute: {
                self.tblList.reloadData()
                userRef.removeObserver(withHandle: self.userRefH)
                if let key = self.searchBar.text {
                    self.perform(#selector(self.queryUsername(_:)), with: key, afterDelay: 0.5)
                }
            })
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    @objc func queryUsername(_ unameKey:String) {
        
        if unameKey.characters.count < 1 {
            return
        }
        
        self.arrSearch.removeAll()
        
        let key = unameKey.lowercased()
        for user in self.arrUsers {
            
            var uname = user["userName"] as! String
            uname = uname.lowercased()
            if uname.contains(key) == true {
                self.arrSearch.append(user)
            }
        }
        
        self.tblList.reloadData()
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if searchBar.text == nil || (searchBar.text?.characters.count)! < 1 {
            return
        }
        let key = searchBar.text
        self.perform(#selector(self.queryUsername(_:)), with: key, afterDelay: 0.5)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSearch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (Bundle.main.loadNibNamed("SearchViewCell", owner: self, options: nil)![0]) as! SearchViewCell
        
        let user = self.arrSearch[indexPath.row]
        cell.lbUsername?.text = user["userName"] as! String?
        
        let photoUrl = user["photoUrl"] as! String?
        self.fetchImageDataAtURL(photoUrl, forImageView: cell.imgUserPhoto)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = self.arrSearch[indexPath.row]
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "friendprofile") as! FriendProfileViewController
        VC.userId = user["userId"] as! String
        self.navigationController?.pushViewController(VC, animated: true)
    }
}


