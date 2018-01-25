//
//  SignupController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase
import SVProgressHUD


class SignupController: UIViewController {
    
    var datePicker = GMDatePicker()
    var dateFormatter = DateFormatter()
    
    lazy var usernameTextField: SkyFloatingLabelTextFieldWithIcon = {
        let textField = SkyFloatingLabelTextFieldWithIcon()
        textField.title = "Username"
        textField.iconFont = UIFont(name: "FontAwesome", size: 20)
        textField.iconText = AssetName.username.rawValue
        textField.placeholder = "Username"
        textField.keyboardType = .default
        textField.setPropertiesForSignUpPage()
        textField.delegate = self
        return textField
    }()
    
    lazy var firstnameTextField: SkyFloatingLabelTextFieldWithIcon = {
        let textField = SkyFloatingLabelTextFieldWithIcon()
        textField.title = "First Name"
        textField.iconFont = UIFont(name: "FontAwesome", size: 20)
        textField.iconText = AssetName.username.rawValue
        textField.placeholder = "First Name"
        textField.keyboardType = .default
        textField.setPropertiesForSignUpPage()
        textField.delegate = self
        return textField
    }()
    
    lazy var lastnameTextField: SkyFloatingLabelTextFieldWithIcon = {
        let textField = SkyFloatingLabelTextFieldWithIcon()
        textField.title = "Last Name"
        textField.iconFont = UIFont(name: "FontAwesome", size: 20)
        textField.iconText = AssetName.username.rawValue
        textField.placeholder = "Last Name"
        textField.keyboardType = .default
        textField.setPropertiesForSignUpPage()
        textField.delegate = self
        return textField
    }()
    
    lazy var birthdayTextField: SkyFloatingLabelTextFieldWithIcon = {
        let textField = SkyFloatingLabelTextFieldWithIcon()
        textField.title = "Birthday(optional)"
        textField.iconFont = UIFont(name: "FontAwesome", size: 20)
        textField.iconText = AssetName.calendar.rawValue
        textField.placeholder = "Birthday(optional)"
        textField.setPropertiesForSignUpPage()
        textField.isUserInteractionEnabled = true
        textField.addTarget(self, action: #selector(handleShowDatePicker), for: .touchDown)
        textField.delegate = self
        return textField
    }()
    
    lazy var emailTextField: SkyFloatingLabelTextFieldWithIcon = {
        let textField = SkyFloatingLabelTextFieldWithIcon()
        textField.title = "Email"
        textField.iconFont = UIFont(name: "FontAwesome", size: 20)
        textField.iconText = AssetName.email.rawValue
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.setPropertiesForSignUpPage()
        textField.delegate = self
        return textField
    }()
    
    lazy var passwordTextField: SkyFloatingLabelTextFieldWithIcon = {
        let textField = SkyFloatingLabelTextFieldWithIcon()
        textField.title = "Password"
        textField.iconFont = UIFont(name: "FontAwesome", size: 20)
        textField.iconText = AssetName.password.rawValue
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.setPropertiesForSignUpPage()
        textField.delegate = self
        return textField
    }()
    
    lazy var signupButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "VisbyRoundCF-Medium", size: 21)
        button.backgroundColor = StyleGuideManager.signinButtonBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        return button
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.cancel.rawValue)?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissController), for: .touchUpInside)
        return button
    }()
    
    lazy var pravacy_termsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("By tapping 'Sign up', you agree to terms and conditions, privacy policy and our EULA agreement.", for: .normal)
        button.titleLabel?.numberOfLines = 0
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "VisbyRoundCF-Medium", size: 18)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePravacy), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
        setupViews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

//MARK: handle calendar
extension SignupController: GMDatePickerDelegate {
    
    func gmDatePicker(_ gmDatePicker: GMDatePicker, didSelect date: Date){
        print(date)
        
        print(dateFormatter.string(from: date))
        
        birthdayTextField.text = dateFormatter.string(from: date)
    }
    func gmDatePickerDidCancelSelection(_ gmDatePicker: GMDatePicker) {
        
    }
    
    func setupDatePicker() {
        
        dateFormatter.dateFormat = "E, MMM d, yyyy"
        
        datePicker.delegate = self
        
        datePicker.config.startDate = Date()
        datePicker.config.animationDuration = 0.5
        
        datePicker.config.cancelButtonTitle = "Cancel"
        datePicker.config.confirmButtonTitle = "Confirm"
        
        datePicker.config.contentBackgroundColor = StyleGuideManager.firstTextColor
        datePicker.config.headerBackgroundColor = StyleGuideManager.secondTextColor
        
        datePicker.config.confirmButtonColor = UIColor.white
        datePicker.config.cancelButtonColor = UIColor.white
        
    }
    
    @objc fileprivate func handleShowDatePicker() {
        
        usernameTextField.resignFirstResponder()
        firstnameTextField.resignFirstResponder()
        lastnameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        datePicker.show(inVC: self)
        
    }
}

//MARK: check valid
extension SignupController {
    
    fileprivate func checkInvalid() -> Bool {
        
        if (usernameTextField.text?.isEmpty)! || !self.isValidUsername(usernameTextField.text!) {
            self.showJHTAlerttOkayWithIcon(message: "Invalid Username!\nPlease type valid Username")
            return false
        }
        
        if (firstnameTextField.text?.isEmpty)! || !self.isValidUsername(firstnameTextField.text!) {
            self.showJHTAlerttOkayWithIcon(message: "Invalid First Name!\nPlease type valid First Name")
            return false
        }
        
        if (lastnameTextField.text?.isEmpty)! || !self.isValidUsername(lastnameTextField.text!) {
            self.showJHTAlerttOkayWithIcon(message: "Invalid Last Name!\nPlease type valid Last Name")
            return false
        }
//
//        if (birthdayTextField.text?.isEmptyStr)! {
//            self.showJHTAlerttOkayWithIcon(message: "Empty Birthday!\nPlease Select Birthday")
//            return false
//        }
//        if !self.isValidBirthday(birthdayTextField.text!) {
//            self.showJHTAlerttOkayWithIcon(message: "Invalid Birthday!\nYou must be over 18 to register!")
//            return false
//        }
//
        if (emailTextField.text?.isEmptyStr)! || !self.isValidEmail(emailTextField.text!) {
            self.showJHTAlerttOkayWithIcon(message: "Invalid Email!\nPlease type valid Email")
            return false
        }
        
        if (passwordTextField.text?.isEmptyStr)! || !self.isValidPassword(passwordTextField.text!) {
            self.showJHTAlerttOkayWithIcon(message: "Invalid Password!\nPlease type valid Password")
            return false
        }
        return true
    }
    
    fileprivate func isValidBirthday(_ birthday: String) -> Bool {
        let birthday = dateFormatter.date(from: birthdayTextField.text!)!
        let currentdate = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day], from: birthday, to: currentdate)
        if components.day! < 365*18 {
            return false
        }
        return true
    }
    
    fileprivate func isValidEmail(_ email: String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    fileprivate func isValidUsername(_ username: String) -> Bool {
        if username.count >= 3 && !username.contains(" ") {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func isValidFirstName(_ firstname: String) -> Bool {
        if firstname.count >= 1 && !firstname.contains(" ") {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func isValidLastName(_ lastname: String) -> Bool {
        if lastname.count >= 1 && !lastname.contains(" ") {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func isValidPassword(_ password: String) -> Bool {
        if password.count >= 5 {
            return true
        } else {
            return false
        }
    }
}

//MARK: handle textfield invalid
extension SignupController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else {
            return false
        }
        
        if textField == usernameTextField {
            
            if let usernameField = textField as? SkyFloatingLabelTextFieldWithIcon {
                if self.isValidUsername(text) {
                    usernameField.errorMessage = ""
                } else {
                    usernameField.errorMessage = "Invalid Username"
                }
            }
            return true
        } else if textField == firstnameTextField {
            if let emailField = textField as? SkyFloatingLabelTextFieldWithIcon {
                
                if self.isValidFirstName(text) {
                    emailField.errorMessage = ""
                } else {
                    emailField.errorMessage = "Invalid First Name"
                }
                
            }
            return true
        } else if textField == lastnameTextField {
            if let emailField = textField as? SkyFloatingLabelTextFieldWithIcon {
                
                if self.isValidLastName(text) {
                    emailField.errorMessage = ""
                } else {
                    emailField.errorMessage = "Invalid Last Name"
                }
                
            }
            return true
        } else if textField == birthdayTextField {
            return false
        } else if textField == emailTextField {
            if let emailField = textField as? SkyFloatingLabelTextFieldWithIcon {
                
                if self.isValidEmail(text) {
                    emailField.errorMessage = ""
                } else {
                    emailField.errorMessage = "Invalid Email"
                }
                
            }
            return true
        } else {
            if let passwordField = textField as? SkyFloatingLabelTextFieldWithIcon {
                if self.isValidPassword(text) {
                    passwordField.errorMessage = ""
                } else {
                    passwordField.errorMessage = "Weak Password"
                }
            }
            return true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == birthdayTextField {
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return view.endEditing(true)
        
    }
}

//MARK: handle Signup
extension SignupController {
    
    @objc fileprivate func handleSignup() {
        if checkInvalid() == false {
            return
        }
        let checkConnection = RKCommon.checkInternetConnection()
        if !checkConnection {
            self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
            return
        }
        let userRef : DatabaseReference  = Database.database().reference().child("userName_Email")
//        userRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
//            if snapshot.hasChild(self.usernameTextField.text!){
//                self.showJHTAlerttOkayWithIcon(message: "Same Username Exist!\nPlease type another Username")
//            } else{
//                self.setUserDefaults()
//            }
//        })
        self.setUserDefaults()
    }
    
    @objc fileprivate func handlePravacy() {
        let urlStr = "https://www.shadesware.com/legal/"
        if let url = NSURL(string:urlStr) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
    
    private func createFirebaseUserWithEmail(_ email: String, username: String, firstname: String, lastname: String, password: String, birthday: String) {
        SVProgressHUD.show(withStatus: "Loading...")
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later")
                print(error!)
                SVProgressHUD.dismiss()
                return
            } else {
                
                
                guard let uid = user?.uid else {
                    SVProgressHUD.dismiss()
                    return
                }
                
                UserDefaults.standard.setUserId(uid)
                UserDefaults.standard.synchronize()
                
                //successfluly authenticated user
                
                //member since date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                let memberSinceDate = Date()
                let memberSinceDateString = dateFormatter.string(from: memberSinceDate)
                let memberSinceString = "Member since \(memberSinceDateString)"
                
                let fullName = firstname + " " + lastname
                
                let values = ["userId": uid, "userName": username, "email": email, "firstName": firstname, "lastName": lastname, "birthday": birthday, "memberSince": memberSinceString, "fullName": fullName]
                
                let userNameEmailValue = [username: email]
                Database.database().reference().child("userName_Email").updateChildValues(userNameEmailValue, withCompletionBlock: { (error, ref) in
                    
                    if error != nil {
                        print(error!)
                        SVProgressHUD.dismiss()
                        self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later")
                        return
                    }
                    self.registerUserIntoDatabaseWithUid(uid: uid, values: values as [String : AnyObject])
                })
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUid(uid: String, values: [String: AnyObject]) {
        
        let ref = Database.database().reference()
        let userReference = ref.child("users").child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                SVProgressHUD.dismiss()
                self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later")
                return
            }
            SVProgressHUD.dismiss()
            self.showJHTAlerttOkayActionWithIcon(message: "Success!", action: { (action) in
                self.handleDismissController()
            })
        })
    }
    
    private func setUserDefaults() {
        
        let userDefaults = UserDefaults.standard
        
        guard let username = usernameTextField.text,
              let firstname = firstnameTextField.text,
              let lastname = lastnameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text,
              let birthday = birthdayTextField.text else {
            return
        }
        userDefaults.setUsername(username)
        userDefaults.setFirstname(firstname)
        userDefaults.setLastname(lastname)
        userDefaults.setBirthday(birthday)
        userDefaults.setEmail(email)
        userDefaults.setUserFullName(firstname + " " + lastname)
        userDefaults.setPassword(password)
        
        self.createFirebaseUserWithEmail(email, username: username, firstname: firstname, lastname: lastname, password: password, birthday: birthday)
    }
    
}

//MARK: handle dismiss
extension SignupController {
    @objc fileprivate func handleDismissController() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: setup views
extension SignupController {
    
    fileprivate func setupViews() {
        setupBackground()
        setupNavBar()
        setupTextFields()
        setupSignupButton()
        setupPravacyPoliceAndTerms()
    }
    
    private func setupPravacyPoliceAndTerms() {
        view.addSubview(pravacy_termsButton)
        _ = pravacy_termsButton.anchor(signupButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 60)
    }
    
    private func setupSignupButton() {
        view.addSubview(signupButton)
        
        _ = signupButton.anchor(passwordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 40)
    }
    
    private func setupTextFields() {
        view.addSubview(usernameTextField)
        view.addSubview(firstnameTextField)
        view.addSubview(lastnameTextField)
        view.addSubview(birthdayTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        
        _ = usernameTextField.anchor(dismissButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 45)
        
        _ = firstnameTextField.anchor(usernameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 45)
        
        _ = lastnameTextField.anchor(firstnameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 45)
        
        _ = birthdayTextField.anchor(lastnameTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 45)
        
        _ = emailTextField.anchor(birthdayTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 45)
        
        _ = passwordTextField.anchor(emailTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 50, bottomConstant: 0, rightConstant: 50, widthConstant: 0, heightConstant: 45)
    }
    
    private func setupNavBar() {
        view.addSubview(dismissButton)
        
        dismissButton.tintColor = .white
        
        _ = dismissButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
    }
    
    private func setupBackground() {
        
        let backgroundImage = UIImage(named: "logo")
        let backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.contentMode = .scaleAspectFit
        
        view.addSubview(backgroundImageView)

        _ = backgroundImageView.anchor(nil, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 200)
        backgroundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        backgroundImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 200).isActive = true
        
    }
    
}


extension SkyFloatingLabelTextFieldWithIcon {
    
    func setPropertiesForSignUpPage() {
        self.tintColor = StyleGuideManager.firstTextColor
        self.selectedTitleColor = StyleGuideManager.firstTextColor
        self.selectedLineColor = StyleGuideManager.firstTextColor
        self.selectedIconColor = StyleGuideManager.firstTextColor
        self.textColor = .white
        self.font = UIFont(name: "VisbyRoundCF-Medium", size: 18)
    }
    
}















