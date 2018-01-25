//
//  ForgotPasswordViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var email: UITextField!
    
    @IBOutlet var emailSentLabel: UILabel!
    
    @IBOutlet var btnSendLink:UIButton!
    
    @IBAction func sendLogin(_ sender: Any) {
        
        if email.text == nil || email.text == "" {
            self.showJHTAlerttOkayWithIcon(message:"Please input a valid email!")
            email.becomeFirstResponder()
            return
        }
        
        self.emailSentLabel.text = ""
        
        SVProgressHUD.show()
        Auth.auth().sendPasswordReset(withEmail: email.text!) { (error) in
            // ...
            SVProgressHUD.dismiss()
            if error == nil {
                self.emailSentLabel.text = "Email Sent!"
            }
            else {
                self.showJHTAlerttOkayWithIcon(message:"Invalid Account!")
            }
        }
        email.resignFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnSendLink.layer.cornerRadius = 5
        btnSendLink.layer.masksToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        email.resignFirstResponder()
    }

}

extension ForgotPasswordViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
