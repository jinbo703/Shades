//
//  LoginController.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import JHTAlertController
import Firebase
import SVProgressHUD

enum LoginType {
    
    case EmailEmpty
    case PasswordEmpty
    case WrongEmail
    case WrongPassword
}

class LoginController: UIViewController {
    
    var parentVC:UIViewController!
    
    let cellId = "cellId"
    
    let pages: [Page] = {
        
        let firstPage = Page(title: "", message: "", imageName: AssetName.firstPage.rawValue, textColor: StyleGuideManager.firstTextColor)
        let secondPage = Page(title: "", message: "", imageName: AssetName.secondPage.rawValue, textColor: StyleGuideManager.secondTextColor)
        let thirdPage = Page(title: "", message: "", imageName: AssetName.thirdPage.rawValue, textColor: StyleGuideManager.thirdTextColor)
        
        return [firstPage, secondPage, thirdPage]
    }()
    
    var alertController: JHTAlertController?
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = StyleGuideManager.secondTextColor
        pc.numberOfPages = self.pages.count
        return pc
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        return cv
    }()
    
    lazy var loginButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "VisbyRoundCF-Medium", size: 21)
        button.backgroundColor = StyleGuideManager.signinButtonBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleShowingSigninAlert), for: .touchUpInside)
        return button
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Forgot your password?", for: .normal)
        button.titleLabel?.font = UIFont(name: "VisbyRoundCF-Light", size: 18)
        button.tintColor  = UIColor.white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        return button
    }()
    
    lazy var signupButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "VisbyRoundCF-Medium", size: 21)
        button.backgroundColor = .clear
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleGoingToSignupController), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
    }
    
    @objc func moveToNextPage() {
        let pageNumber = pageControl.currentPage
        if pageNumber == 0 {
            pageControl.currentPage = 1
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            self.loginButton.backgroundColor = StyleGuideManager.secondTextColor
            self.pageControl.currentPageIndicatorTintColor = StyleGuideManager.secondTextColor
        } else if pageNumber == 1 {
            pageControl.currentPage = 2
            let indexPath = IndexPath(row: 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            self.loginButton.backgroundColor = StyleGuideManager.thirdTextColor
            self.pageControl.currentPageIndicatorTintColor = StyleGuideManager.thirdTextColor
        } else {
            pageControl.currentPage = 0
            let indexPath = IndexPath(row: 2, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .right, animated: true)
            self.loginButton.backgroundColor = StyleGuideManager.firstTextColor
            self.pageControl.currentPageIndicatorTintColor = StyleGuideManager.firstTextColor
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserver()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

//MARK: handle Forgot password
extension LoginController {
    
    @objc fileprivate func handleForgotPassword() {
        
        alertController = JHTAlertController(title: "", message: "Forgot password?\nType your email.", preferredStyle: .alert)
        alertController?.titleImage = UIImage(named: AssetName.alertIcon.rawValue)
        alertController?.titleViewBackgroundColor = .white
        alertController?.titleTextColor = .black
        alertController?.alertBackgroundColor = .white
        alertController?.messageFont = UIFont(name: "VisbyRoundCF-Medium", size: 17)
        alertController?.messageTextColor = .black
        alertController?.dividerColor = .black
        alertController?.setButtonTextColorFor(.default, to: .white)
        alertController?.setButtonBackgroundColorFor(.default, to: StyleGuideManager.signinButtonBackgroundColor)
        alertController?.setButtonTextColorFor(.cancel, to: .black)
        alertController?.setButtonBackgroundColorFor(.cancel, to: .white)
        alertController?.hasRoundedCorners = true
        
        let cancelAction = JHTAlertAction(title: "Later", style: .cancel,  handler: nil)
        let okAction = JHTAlertAction(title: "Send", style: .default) { (action) in
            
            guard let emailTextField = self.alertController?.textFields?.first else { return }
            
            guard let emailStr = emailTextField.text else { return }
            
            if emailStr.isEmpty {
                self.showJHTAlerttOkayWithIcon(message: "Oops! Type your email.")
                return
            }
            
            let checkConnection = RKCommon.checkInternetConnection()
            if !checkConnection {
                self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
                return
            }
            
            SVProgressHUD.show(withStatus: "Please wait...")
            
            Auth.auth().sendPasswordReset(withEmail: emailStr, completion: { (error) in
                
                if error != nil {
                    print("forgot password error: ", error!)
                    SVProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later.")
                } else {
                    SVProgressHUD.dismiss()
                    self.showJHTAlerttOkayWithIcon(message: "Success!\nPlease check your email.")
                }
            })
            
        }
        
        alertController?.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Email"
            textField.backgroundColor = .white
            textField.textColor = .black
            textField.keyboardType = .emailAddress
            textField.borderStyle = .roundedRect
            textField.font = UIFont(name: "VisbyRoundCF-Medium", size: 18)
        }
        
        alertController?.addAction(cancelAction)
        alertController?.addAction(okAction)
        
        present(alertController!, animated: true, completion: nil)
        
    }
    
}

//MARK: handle keyboard
extension LoginController: UITextFieldDelegate {
    
    fileprivate func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc fileprivate func keyboardWillShow() {
        guard let rect = self.alertController?.view.frame else { return }
        if rect.origin.y >= 0 {
            self.setViewMoveUp(moveUp: true)
        }
    }
    
    @objc fileprivate func keyboardWillHide() {
        guard let rect = self.alertController?.view.frame else { return }
        if rect.origin.y < 0 {
            self.setViewMoveUp(moveUp: false)
        }
    }
    
    private func setViewMoveUp(moveUp: Bool) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        guard var rect = self.alertController?.view.frame else { return }
        if moveUp {
            rect.origin.y -= kOFFSET_FOR_KEYBOARD
            rect.size.height += kOFFSET_FOR_KEYBOARD
        } else {
            rect.origin.y += kOFFSET_FOR_KEYBOARD
            rect.size.height -= kOFFSET_FOR_KEYBOARD
        }
        self.alertController?.view.frame = rect
        UIView.commitAnimations()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.tag == 1 {
            guard let rect = self.alertController?.view.frame else { return }
            if rect.origin.y >= 0 {
                self.setViewMoveUp(moveUp: true)
            }
        }
    }
}

//MARK: handle signup, sign in
extension LoginController {
    
    @objc fileprivate func handleGoingToSignupController() {
        
        let signupController = SignupController()
        present(signupController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleShowingSigninAlert() {
        self.handleShowingLoginAlertWithEmail(nil, password: nil)
    }
    
    fileprivate func handleShowingLoginAlertWithEmail(_ email: String?, password: String?) {
        
        alertController = JHTAlertController(title: "", message: "Please make sure you typed your Email and Password correctly!", preferredStyle: .alert)
        alertController?.titleImage = UIImage(named: AssetName.loginIcon.rawValue)
        alertController?.titleViewBackgroundColor = .white
        alertController?.titleTextColor = .black
        alertController?.alertBackgroundColor = .white
        alertController?.messageFont = UIFont(name: "VisbyRoundCF-Medium", size: 17)
        alertController?.messageTextColor = .black
        alertController?.dividerColor = .black
        alertController?.setButtonTextColorFor(.default, to: .white)
        alertController?.setButtonBackgroundColorFor(.default, to: StyleGuideManager.signinButtonBackgroundColor)
        alertController?.setButtonTextColorFor(.cancel, to: .black)
        alertController?.setButtonBackgroundColorFor(.cancel, to: .white)
        alertController?.hasRoundedCorners = true
        
        let cancelAction = JHTAlertAction(title: "Later", style: .cancel,  handler: nil)
        let okAction = JHTAlertAction(title: "Log in", style: .default) { (action) in
            
            guard let emailTextField = self.alertController?.textFields?.first else { return }
            guard let passwordTextField = self.alertController?.textFields?[1] else { return }
            
            guard let emailStr = emailTextField.text else { return }
            guard let passwordStr = passwordTextField.text else { return }
            
            if emailStr.isEmpty {
                self.handleShowingLoginErrorAletWithLoginType(.EmailEmpty, email: nil, password: nil)
                return
            }
            
            if passwordStr.isEmpty {
                self.handleShowingLoginErrorAletWithLoginType(.PasswordEmpty, email: emailStr, password: nil)
                return
            }
            
            let checkConnection = RKCommon.checkInternetConnection()
            if !checkConnection {
                self.showJHTAlerttOkayWithIcon(message: "Connection Error!\nPlease check your internet connection")
                return
            }
            
            self.handleLoginWithEmail(emailStr, password: passwordStr)
        }
        
        alertController?.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Username/Email"
            textField.backgroundColor = .white
            textField.textColor = .black
            textField.keyboardType = .emailAddress
            textField.borderStyle = .roundedRect
            textField.font = UIFont(name: "VisbyRoundCF-Medium", size: 18)
            if let email = email {
                textField.text = email
            }
        }
        
        alertController?.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.backgroundColor = .white
            textField.textColor = .black
            textField.isSecureTextEntry = true
            textField.borderStyle = .roundedRect
            textField.font = UIFont(name: "VisbyRoundCF-Medium", size: 18)
            if let password = password {
                textField.text = password
            }
        }
        
        alertController?.addAction(cancelAction)
        alertController?.addAction(okAction)
        
        present(alertController!, animated: true, completion: nil)
        
    }
    
    private func handleShowingLoginErrorAletWithLoginType(_ loginType: LoginType, email: String?, password: String?) {
        
        var errorMessage = ""
        if loginType == .EmailEmpty {
            errorMessage = "You missed typing Email/Username!\nTry again?"
        } else if loginType == .PasswordEmpty {
            errorMessage = "You missed typing Password!\nTry again?"
        } else if loginType == .WrongEmail {
            errorMessage = "You typed wrong Email/Username!\nTry again?"
        } else if loginType == .WrongPassword {
            errorMessage = "You typed wrong Password!\nTry again?"
        }
        
        self.showJHTAlertDefaultWithIcon(message: errorMessage, firstActionTitle: "Later", secondActionTitle: "Yes") { (action) in
            self.handleShowingLoginAlertWithEmail(email, password: password)
        }
        
    }
    
    private func handleLoginWithEmail(_ email: String, password: String) {
        
        if self.isValidEmail(email) {
            self.checkUserDefaultsWithEmail(email, password: password)
        } else {
            self.retrieveUserEmailWithUserName(email, completion: { (realEmail) in
                if let realEmail = realEmail {
                    self.checkUserDefaultsWithEmail(realEmail, password: password)
                }
            })
        }
    }
    
    private func retrieveUserEmailWithUserName(_ userName: String, completion: @escaping ((_ email: String?) -> Void)) {
        
        Database.database().reference().child("userName_Email").child(userName).observeSingleEvent(of: .value, with: { (snapshot) in
            if let email = snapshot.value as? String {
                completion(email)
            }
        })
        
    }
    
    private func checkUserDefaultsWithEmail(_ email: String, password: String) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error!)
                SVProgressHUD.dismiss()
                self.showJHTAlerttOkayWithIcon(message: "Something went wrong!\nTry again later")
                return
            }
            if let user = Auth.auth().currentUser {
                SVProgressHUD.dismiss()
                UserDefaults.standard.setUserId(user.uid)
                UserDefaults.standard.setPassword(password)
                UserDefaults.standard.setEmail(email)
                UserDefaults.standard.synchronize()
                self.finishLoggingIn()
            }
        })
    }
    
    private func finishLoggingIn()  {
        
        UserDefaults.standard.setIsLoggedIn(value: true)
        
        let userid = UserDefaults.standard.getUserId()
        SVProgressHUD.show()
        Database.database().reference().child("users").queryOrdered(byChild: "userId").queryEqual(toValue: userid).observe(.value, with:{ (snapshot: DataSnapshot) in
            
            for snap in snapshot.children {
                
                let user = (snap as! DataSnapshot).value as! Dictionary<String, AnyObject>
                
                UserDefaults.standard.setUserFullName(user["fullName"]! as! String)
                UserDefaults.standard.setUsername(user["userName"]! as! String)
                UserDefaults.standard.setFirstname(user["firstName"]! as! String)
                UserDefaults.standard.setLastname(user["lastName"]! as! String)
                UserDefaults.standard.setBirthday(user["birthday"]! as! String)
                UserDefaults.standard.setUserCreatedDate(user["memberSince"]! as! String)
                UserDefaults.standard.setBirthday(user["birthday"]! as! String)
                var photoUrl = ""
                if user["photoUrl"] != nil {
                    photoUrl = (user["photoUrl"])! as! String
                }
                UserDefaults.standard.setUserPhotoUrl(photoUrl)
                UserDefaults.standard.synchronize()
                SVProgressHUD.dismiss()
                
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: false, completion:{
                        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recorderView")
                        let navVC = UINavigationController(rootViewController: VC)
                        self.parentVC.present(navVC, animated: false, completion: {
                            LoginController.clearAllFilesFromTempDirectory()
                        })
                    })
                })
                break
            }
        })
    }
    
}

//MARK: check valid
extension LoginController {
    
    fileprivate func isValidEmail(_ email: String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    fileprivate func isValidPassword(_ password: String) -> Bool {
        if password.count >= 5 {
            return true
        } else {
            return false
        }
    }
}

//MARK: handle scroll
extension LoginController {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        if pageNumber == 0 {
            self.loginButton.backgroundColor = StyleGuideManager.secondTextColor
            self.pageControl.currentPageIndicatorTintColor = StyleGuideManager.secondTextColor
        } else if pageNumber == 1 {
            self.loginButton.backgroundColor = StyleGuideManager.thirdTextColor
            self.pageControl.currentPageIndicatorTintColor = StyleGuideManager.thirdTextColor
        } else {
            self.loginButton.backgroundColor = StyleGuideManager.firstTextColor
            self.pageControl.currentPageIndicatorTintColor = StyleGuideManager.firstTextColor
        }
        pageControl.currentPage = pageNumber
        
    }
}

//MARK: handle collectonview delegate, datasource, flowlayout
extension LoginController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        let page = pages[indexPath.item]
        cell.page = page
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}


//MARK: setup views
extension LoginController {
    
    fileprivate func setupViews() {
        setupCollectionView()
        setupPageControl()
        signinStuff()
    }
    
    private func signinStuff() {
        
        view.addSubview(signupButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(loginButton)
        
        signupButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        signupButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signupButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -10).isActive = true
        
        forgotPasswordButton.widthAnchor.constraint(equalTo: signupButton.widthAnchor).isActive = true
        forgotPasswordButton.centerXAnchor.constraint(equalTo: signupButton.centerXAnchor).isActive = true
        forgotPasswordButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        forgotPasswordButton.bottomAnchor.constraint(equalTo: signupButton.topAnchor, constant: -25).isActive = true
        
        loginButton.widthAnchor.constraint(equalTo: signupButton.widthAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalTo: signupButton.heightAnchor).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: signupButton.centerXAnchor).isActive = true
        loginButton.bottomAnchor.constraint(equalTo: forgotPasswordButton.topAnchor, constant: -10).isActive = true
        
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        
        _ = pageControl.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 30)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    fileprivate func setupStatusBar() {
        let statusBarBackgroundView = UIView()
        statusBarBackgroundView.backgroundColor = StyleGuideManager.loginStatusBarColor
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(statusBarBackgroundView)
            window.addConnstraintsWith(Format: "H:|[v0]|", views: statusBarBackgroundView)
            window.addConnstraintsWith(Format: "V:|[v0(20)]", views: statusBarBackgroundView)
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
    
}































