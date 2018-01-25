//
//  LoginViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet var emailOrUsrname: UITextField!

    @IBOutlet var Password: UITextField!
    
    @IBOutlet var btnLogin: UIButton!
    
    var userRef: DatabaseReference!
    var userRefHandle: DatabaseHandle?
    
    var bCheckConnected = false
    
    @IBAction func backAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let forgotViewController = self.storyboard?.instantiateViewController(withIdentifier: "forgotView") as! ForgotPasswordViewController
        self.navigationController?.pushViewController(forgotViewController, animated: true)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        if emailOrUsrname.text == nil || emailOrUsrname.text == "" {
            self.showJHTAlerttOkayWithIcon(message:"Please input a valid email!")
            emailOrUsrname.becomeFirstResponder()
            return
        }
        
        if Password.text == nil || Password.text == "" {
            self.showJHTAlerttOkayWithIcon(message:"Please input a valid password!")
            Password.becomeFirstResponder()
            return
        }
        emailOrUsrname.resignFirstResponder()
        Password.resignFirstResponder()

        SVProgressHUD.show()
        login()
    }
    
    @objc func checkFirebaseConnection() {
        
        if self.bCheckConnected == false {
            SVProgressHUD.dismiss()
            self.showJHTAlerttOkayWithIcon(message:"Failed connection to server! Please check your network status!")
        }
    }
    
    func login() {
        
        self.bCheckConnected = false
        self.perform(#selector(self.checkFirebaseConnection), with: nil, afterDelay: 15.0)
        Auth.auth().signIn(withEmail: emailOrUsrname.text!, password: Password.text!, completion:{ (user, error) in
            
            self.bCheckConnected = true
            if error != nil {
                
                self.bCheckConnected = false
                self.perform(#selector(self.checkFirebaseConnection), with: nil, afterDelay: 15.0)
                self.queryUsername(_uname: self.emailOrUsrname.text!)
                return
            }
            else {
                if UserDefaults.standard.object(forKey: "email") == nil {
                    
                    UserDefaults.standard.set((user?.uid)!, forKey: "user_id")
                    UserDefaults.standard.set(self.emailOrUsrname.text, forKey: "email")
                    UserDefaults.standard.set(self.Password.text, forKey: "password")
                    UserDefaults.standard.set(true, forKey: "loggedin")
                    UserDefaults.standard.synchronize()

                    self.queryUserWith(_email: self.emailOrUsrname.text!)
                    self.bCheckConnected = false
                    self.perform(#selector(self.checkFirebaseConnection), with: nil, afterDelay: 15.0)
                    return
                }

                print("Successed log in!")
                UserDefaults.standard.set((user?.uid)!, forKey: "user_id")
                UserDefaults.standard.set(self.emailOrUsrname.text, forKey: "email")
                UserDefaults.standard.set(self.Password.text, forKey: "password")
                UserDefaults.standard.set(true, forKey: "loggedin")
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                self.gotoCameraView()
            }
            
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     // Dismiss the keyboard when the view is tapped on
         emailOrUsrname.resignFirstResponder()
         Password.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnLogin.layer.cornerRadius = 5
        btnLogin.layer.masksToBounds = true
        
        userRef = Database.database().reference().child("Users")
        
        if UserDefaults.standard.object(forKey: "email") != nil {
            let email = UserDefaults.standard.object(forKey: "email") as! String!
            if email != nil {
                self.emailOrUsrname.text = email
            }
//            let password = UserDefaults.standard.object(forKey: "password") as! String!
//            if password != nil {
//                self.Password.text = password
//            }
        }
    }

    static func clearAllFilesFromTempDirectory() {
        
        let fileManager = FileManager.default
        let tempDirPath = NSTemporaryDirectory() as NSString
        do {
            let directoryContents = try fileManager.contentsOfDirectory(atPath: tempDirPath as String) as NSArray?
            if directoryContents != nil {
                for path in directoryContents! {
                    let fullPath = tempDirPath.appendingPathComponent(path as! String)
                    do {
                        try fileManager.removeItem(atPath: fullPath)
                    } catch {
                        print("Could not delete file!")
                    }
                }
            } else {
                print("Could not retrieve directory!")
            }
        } catch  {
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeRefHandle()
    }
    
    @objc func removeRefHandle() {
        
        if let refHandle = userRefHandle {
            userRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func hideProgressHUD() {
        
        SVProgressHUD.dismiss()
    }
    
    
    func queryUsername(_uname:String) {
        
        let ref = userRef.queryOrdered(byChild: "username").queryEqual(toValue : _uname)
        
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            
            self.bCheckConnected = true
            SVProgressHUD.dismiss()
            for snap in snapshot.children {
                let userData = (snap as! DataSnapshot).value as! Dictionary<String, String>
                let username = userData["username"]
                let email = userData["email"]!
                let birthday = userData["birthday"]
                let firstname = userData["firstname"]
                let lastname = userData["lastname"]
                let createdTime = userData["createdAt"]
                
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(username, forKey: "username")
                UserDefaults.standard.set(firstname, forKey: "fname")
                UserDefaults.standard.set(lastname, forKey: "lname")
                UserDefaults.standard.set(birthday, forKey: "birthday")
                UserDefaults.standard.set(createdTime, forKey: "createdAt")
                UserDefaults.standard.synchronize()
                
                SVProgressHUD.show()
                DispatchQueue.main.async(execute: {
                    self.loginWithUsername(email)
                    self.bCheckConnected = false
                    self.perform(#selector(self.checkFirebaseConnection), with: nil, afterDelay: 15.0)
                })
                break
            }
        })
    }
    
    func queryUserWith(_email:String) {
        
        let ref = userRef.queryOrdered(byChild: "email").queryEqual(toValue : _email)
        
        ref.observe(.value, with:{ (snapshot: DataSnapshot) in
            
            self.bCheckConnected = true
            SVProgressHUD.dismiss()
            for snap in snapshot.children {
                let userData = (snap as! DataSnapshot).value as! Dictionary<String, String>
                let username = userData["username"]
                let email = userData["email"]!
                let birthday = userData["birthday"]
                let firstname = userData["firstname"]
                let lastname = userData["lastname"]
                let createdTime = userData["createdAt"]
                
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(username, forKey: "username")
                UserDefaults.standard.set(firstname, forKey: "fname")
                UserDefaults.standard.set(lastname, forKey: "lname")
                UserDefaults.standard.set(birthday, forKey: "birthday")
                UserDefaults.standard.set(createdTime, forKey: "createdAt")
                UserDefaults.standard.synchronize()
                
                DispatchQueue.main.async(execute: {
                    self.gotoCameraView()
                })
                break
            }
        })
    }
    
    func observeUsers() {
        
        userRefHandle = userRef.observe(.childAdded, with: { (snapshot) -> Void in
        })
    }
    
    func loginWithUsername(_ email: String) {
        
        Auth.auth().signIn(withEmail: email, password: Password.text!, completion:{ (user, error) in
            
            self.bCheckConnected = true
            if error != nil {
                print("Incorrect Username")
                self.showJHTAlerttOkayWithIcon(message:"Invalid Account!")
                SVProgressHUD.dismiss()
                return
            }
            else {
                
                print("Successed log in!")
                UserDefaults.standard.set((user?.uid)!, forKey: "user_id")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(self.Password.text, forKey: "password")
                UserDefaults.standard.set(true, forKey: "loggedin")
                UserDefaults.standard.synchronize()
                //go to home view
                SVProgressHUD.dismiss()
                self.gotoCameraView()
            }
            
        })
    }
    
    func gotoCameraView() {
        
        LoginViewController.clearAllFilesFromTempDirectory()
        
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "recorderView") as! RecordViewController
        let navVC = UINavigationController(rootViewController: VC)
        self.present(navVC, animated: false, completion: nil)
    }
}

extension LoginViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
