//
//  SignupViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    // variables to store First Name & Last Name
    
    @IBOutlet var fName: UITextField!
    
    @IBOutlet var LName: UITextField!
    
    @IBOutlet var btnSignup: UIButton!
    
    @IBAction func backAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
            
    @IBAction func SignUpAccept(_ sender: Any) {
        
        if fName.text == nil || fName.text == "" {
            self.showJHTAlerttOkayWithIcon(message:"Please input a valid firstname!")
            fName.becomeFirstResponder()
            return
        }
        
        if LName.text == nil || LName.text == "" {
            self.showJHTAlerttOkayWithIcon(message:"Please input a valid lastname!")
            LName.becomeFirstResponder()
            return
        }
        
        UserDefaults.standard.set(self.fName.text, forKey: "fname")
        UserDefaults.standard.set(self.LName.text, forKey: "lname")
        UserDefaults.standard.synchronize()
        
        let birthdayViewController = self.storyboard?.instantiateViewController(withIdentifier: "birthdayView") as! BirthdayViewController
        self.navigationController?.pushViewController(birthdayViewController, animated: true)
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        fName.resignFirstResponder()
        LName.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnSignup.layer.cornerRadius = 5
        btnSignup.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension SignupViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
