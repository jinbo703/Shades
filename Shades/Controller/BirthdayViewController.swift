//
//  BirthdayViewController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class BirthdayViewController: UIViewController {
    
    // variable to store birthday
    var birthday: Date!
  
    //variables to store received
    var namePass = String()
    var lnamePass = String()
    
    // var to retrieve 
    var namePass2 = String()
    var lnamePass2 = String()
    
    @IBOutlet var btnContinue: UIButton!
    
    @IBOutlet var birthdayVal: UIDatePicker!
    
    
    @IBAction func birthdayContinue(_ sender: Any) {
        
        birthday = birthdayVal.date
        
        let today = NSDate()
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let age = gregorian.components([.year], from: birthday!, to: today as Date, options: [])
        
        if age.year! >= 18 {
            // user is under 18
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let birth = dateFormatter.string(from: birthday as Date)
            
            UserDefaults.standard.set(birth, forKey: "birthday")
            UserDefaults.standard.synchronize()
            
            let usernameViewController = self.storyboard?.instantiateViewController(withIdentifier: "usernameView") as! UsernameViewController
            self.navigationController?.pushViewController(usernameViewController, animated: true)
        }
        else {
            self.showJHTAlerttOkayWithIcon(message:"Please select a older year than 18 years old!")
        }
        
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        namePass = namePass2
        lnamePass = lnamePass2
        
        btnContinue.layer.cornerRadius = 5
        btnContinue.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
