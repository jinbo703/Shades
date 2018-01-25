//
//  PasswordViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import Firebase

class PasswordViewController: UIViewController {
    
    let usersRef = Database.database().reference(withPath: "Users")
    
    var userRef: DatabaseReference!
    var userRefHandle: DatabaseHandle?
    
    @IBOutlet var btnRegister: UIButton!
    
    @IBOutlet var password: UITextField!
    
    var bCheckConnected = false


    @IBAction func backAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        if password.text == nil || ( (password.text?.characters.count)! < 8 ) {
            self.showJHTAlerttOkayWithIcon(message:"Password must be more than 8 characters!")
            return
        }
        bCheckConnected = false
        SVProgressHUD.show()
        let uname = UserDefaults.standard.object(forKey: "username") as! String
        self.queryUsername(_uname:uname)
        self.perform(#selector(self.checkFirebaseConnection), with: nil, afterDelay: 15.0)
    }
    
    @objc func checkFirebaseConnection() {
        
        if self.bCheckConnected == false {
            SVProgressHUD.dismiss()
            self.registerUser()
        }
    }
    
    func registerUser() {
        
        let pwd = password.text!
        
        let fname = UserDefaults.standard.object(forKey: "fname") as! String
        let lname = UserDefaults.standard.object(forKey: "lname") as! String
        let email = UserDefaults.standard.object(forKey: "email") as! String
        let uname = UserDefaults.standard.object(forKey: "username") as! String
        let birthday = UserDefaults.standard.object(forKey: "birthday") as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdTime = dateFormatter.string(from: NSDate() as Date)
        
        // create dict with user info to push into database
        let userRef: [String: String] =
            [
                "email":    email,
                "username": uname,
                "firstname":fname,
                "lastname": lname,
                "birthday": birthday,
                "createdAt": createdTime,
                "userphoto": ""
            ]
        
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: email, password: pwd) { (user, error) in
            
            self.bCheckConnected = true
            SVProgressHUD.dismiss()
            if error == nil {
                print("You are successfully registered")
                print(userRef)
                self.usersRef.childByAutoId().setValue(userRef)
                
                UserDefaults.standard.set((user?.uid)!, forKey: "user_id")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(pwd, forKey: "password")
                UserDefaults.standard.set(createdTime, forKey: "createdAt")
                UserDefaults.standard.set(true, forKey: "loggedin")
                UserDefaults.standard.synchronize()
                
                LoginViewController.clearAllFilesFromTempDirectory()
                
                DispatchQueue.main.async(execute: {
                    //Run UI Updates
                    let VC = self.storyboard?.instantiateViewController(withIdentifier: "recorderView") as! RecordViewController
                    let navVC = UINavigationController(rootViewController: VC)
                    self.present(navVC, animated: false, completion: nil)
                })
            }
            else{
                print("Registration Failed.. Please Try Again")
                print(error?.localizedDescription ?? "")
                self.showJHTAlerttOkayWithIcon(message:error?.localizedDescription ?? "")
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRegister.layer.cornerRadius = 5
        btnRegister.layer.masksToBounds = true
        
        userRef = Database.database().reference().child("Users")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        password.resignFirstResponder()
    }

    
    func queryUsername(_uname:String) {
        
        let ref = userRef.queryOrdered(byChild: "username").queryEqual(toValue : _uname)
        
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            
            self.bCheckConnected = true
            SVProgressHUD.dismiss()
            var bExist:Bool = false
            for snap in snapshot.children {
                let userData = (snap as! DataSnapshot).value as! Dictionary<String, String>
                _ = userData["username"]
                _ = userData["email"]!
                
                bExist = true
                self.showJHTAlerttOkayWithIcon(message:"This username already exists! Please try other username!")
                break
            }
            if bExist == false {
                SVProgressHUD.show()
                let email = UserDefaults.standard.object(forKey: "email") as! String
                self.queryUserWith(_email:email)
                self.bCheckConnected = false
                self.perform(#selector(self.checkFirebaseConnection), with: nil, afterDelay: 15.0)
            }
        })
    }
    
    func queryUserWith(_email:String) {
        
        let ref = userRef.queryOrdered(byChild: "email").queryEqual(toValue : _email)
        
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            
            self.bCheckConnected = true
            SVProgressHUD.dismiss()
            var bExist:Bool = false
            for snap in snapshot.children {
                let userData = (snap as! DataSnapshot).value as! Dictionary<String, String>
                _ = userData["username"]
                _ = userData["email"]!
                
                bExist = true
                self.showJHTAlerttOkayWithIcon(message:"This email already exists! Please try other email!")
                break
            }
            if bExist == false {
                self.registerUser()
            }
        })
    }
    
}

extension PasswordViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

