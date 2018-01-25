//
//  UsernameViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//
import UIKit
import Foundation

class UsernameViewController : UIViewController {
    
    @IBOutlet var usernameName: UITextField!
    
    @IBOutlet var email: UITextField!
    
    @IBOutlet var btnContinue: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        btnContinue.layer.cornerRadius = 5
        btnContinue.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func continueClicked(_ sender: Any) {
        
        if usernameName.text == nil || usernameName.text == "" {
            self.showJHTAlerttOkayWithIcon(message:"Please input a valid username!")
            usernameName.becomeFirstResponder()
            return
        }
        
        if email.text == nil || email.text == "" {
            self.showJHTAlerttOkayWithIcon(message:"Please input a valid email!")
            email.becomeFirstResponder()
            return
        }
        
        UserDefaults.standard.set(self.email.text, forKey: "email")
        UserDefaults.standard.set(self.usernameName.text, forKey: "username")
        UserDefaults.standard.synchronize()
        
        let passwordViewController = self.storyboard?.instantiateViewController(withIdentifier: "passwordView") as! PasswordViewController
        self.navigationController?.pushViewController(passwordViewController, animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        usernameName.resignFirstResponder()
        email.resignFirstResponder()
    }

}

extension UsernameViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

