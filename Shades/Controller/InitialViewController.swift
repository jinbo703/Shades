//
//  ViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Photos
import MediaPlayer
import AVFoundation
import SVProgressHUD

class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                } else {
                }
            })
        }
        
        if #available(iOS 9.3, *) {
            let medias = MPMediaLibrary.authorizationStatus()
            if medias == .notDetermined {
                MPMediaLibrary.requestAuthorization { (status) in
                    if status == .authorized {
                    } else {
                    }
                }
            }
        }
        
        self.gotoCameraView()
    }
    
    
    @objc func gotoCameraView() {

        if isLoggedIn() {
            let email = UserDefaults.standard.getEmail()
            let password = UserDefaults.standard.getPassword()
            checkUserDefaultsWithEmail(email!, password: password!)
        } else {
            perform(#selector(showLoginController), with: nil, afterDelay: 0.01)
        }
    }
    
    private func checkUserDefaultsWithEmail(_ email: String, password: String) {
       
        let checkConnection = RKCommon.checkInternetConnection()
        if !checkConnection {
            self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
            return
        }
        
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                self.perform(#selector(self.showLoginController), with: nil, afterDelay: 0.01)
                return
            }
            if let user = Auth.auth().currentUser {
                
                if !user.isEmailVerified {
                    SVProgressHUD.dismiss()
                    self.perform(#selector(self.showLoginController), with: nil, afterDelay: 0.01)
                } else {
                    SVProgressHUD.dismiss()
                    self.finishLoggingIn()
                }
            }
        })
    }
    
    private func finishLoggingIn()  {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "recorderView") as! RecordViewController
        let navVC = UINavigationController(rootViewController: VC)
        self.present(navVC, animated: false, completion: nil)
    }
    
    fileprivate func isLoggedIn() -> Bool {
        return UserDefaults.standard.isLoggedIn()
    }
    
    @objc func showLoginController() {
        let loginController = LoginController()
        loginController.parentVC = self
        present(loginController, animated: true, completion: {
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(_ sender: Any) {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
   
    @IBAction func signup(_ sender: Any) {
        let SignupViewController = self.storyboard?.instantiateViewController(withIdentifier: "signupView") as! SignupViewController
        self.navigationController?.pushViewController(SignupViewController, animated: true)
    }
}

