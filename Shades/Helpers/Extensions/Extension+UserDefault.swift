//
//  Extension+UserDefault.swift
//  Shades
//
//  Created by John Nik on 11/17/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation
extension UserDefaults {
    
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
        case fullname
        case username
        case firstname
        case lastname
        case birthday
        case email
        case password
        case userid
        case createdAt
        case photourl
    }
    
    //MARK: check login
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    //MARK: save user full name
    func setUserFullName(_ fullname: String) {
        set(fullname, forKey: UserDefaultsKeys.fullname.rawValue)
        synchronize()
    }
    
    func getFullname() -> String? {
        if let fullname = string(forKey: UserDefaultsKeys.fullname.rawValue) {
            return fullname
        }
        return nil
    }
    
    //MARK: save username
    func setUsername(_ username: String) {
        set(username, forKey: UserDefaultsKeys.username.rawValue)
        synchronize()
    }
    
    func getUsername() -> String? {
        if let username = string(forKey: UserDefaultsKeys.username.rawValue) {
            return username
        }
        return nil
    }
    
    //MARK: save firstname
    func setFirstname(_ firstname: String) {
        set(firstname, forKey: UserDefaultsKeys.firstname.rawValue)
        synchronize()
    }
    
    func getFirstname() -> String? {
        if let firstname = string(forKey: UserDefaultsKeys.firstname.rawValue) {
            return firstname
        }
        return nil
    }
    
    //MARK: save lastname
    func setLastname(_ lastname: String) {
        set(lastname, forKey: UserDefaultsKeys.lastname.rawValue)
        synchronize()
    }
    
    func getLastname() -> String? {
        if let lastname = string(forKey: UserDefaultsKeys.lastname.rawValue) {
            return lastname
        }
        return nil
    }
    
    //MARK: save birthday
    func setBirthday(_ birthday: String) {
        set(birthday, forKey: UserDefaultsKeys.birthday.rawValue)
        synchronize()
    }
    
    func getBirthday() -> String? {
        if let birthday = string(forKey: UserDefaultsKeys.birthday.rawValue) {
            return birthday
        }
        return nil
    }
    
    //MARK: save email
    func setEmail(_ email: String) {
        set(email, forKey: UserDefaultsKeys.email.rawValue)
        synchronize()
    }
    
    func getEmail() -> String? {
        if let email = string(forKey: UserDefaultsKeys.email.rawValue) {
            return email
        }
        return nil
    }
    
    //MARK: save user password
    func setPassword(_ password: String) {
        set(password, forKey: UserDefaultsKeys.password.rawValue)
        synchronize()
    }
    
    func getPassword() -> String? {
        if let password = string(forKey: UserDefaultsKeys.password.rawValue) {
            return password
        }
        return nil
    }
    
    //MARK: save user password
    func setUserId(_ userid: String) {
        set(userid, forKey: UserDefaultsKeys.userid.rawValue)
        synchronize()
    }
    
    func getUserId() -> String? {
        if let userid = string(forKey: UserDefaultsKeys.userid.rawValue) {
            return userid
        }
        return nil
    }
    
    //MARK: save user password
    func setUserCreatedDate(_ date: String) {
        set(date, forKey: UserDefaultsKeys.createdAt.rawValue)
        synchronize()
    }
    
    func getUserCreatedDate() -> String? {
        if let date = string(forKey: UserDefaultsKeys.createdAt.rawValue) {
            return date
        }
        return nil
    }
    
    //MARK: save user password
    func setUserPhotoUrl(_ url: String) {
        set(url, forKey: UserDefaultsKeys.photourl.rawValue)
        synchronize()
    }
    
    func getUserPhotoUrl() -> String? {
        if let url = string(forKey: UserDefaultsKeys.photourl.rawValue) {
            return url
        }
        return nil
    }
}
