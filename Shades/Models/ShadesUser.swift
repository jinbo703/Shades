//
//  ShadesUser.swift
//  Shades
//
//  Created by John Nik on 11/20/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class ShadesUser: NSObject {
    
    var userId: String?
    var userName: String?
    var firstName: String?
    var lastName: String?
    var fullName: String?
    var photoUrl: String?
    var memberSince: String?
    var bio: String?
    var birthday: String?
    var email: String?
    
    init(dictionary: [String: AnyObject]) {
        
        userId = dictionary["userId"] as? String
        userName = dictionary["userName"] as? String
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        fullName = dictionary["fullName"] as? String
        photoUrl = dictionary["photoUrl"] as? String
        memberSince = dictionary["memberSince"] as? String
        bio = dictionary["bio"] as? String
        birthday = dictionary["birthday"] as? String
        
    }
    
}
