//
//  StyleGuideManager.swift
//  Shades
//
//  Created by John Nik on 11/17/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

public class StyleGuideManager {
    private init(){}
    
    static let sharedInstance : StyleGuideManager = {
        let instance = StyleGuideManager()
        return instance
    }()
    
    //intro
    static let signinButtonColor = UIColor(r: 0, g: 204, b: 253)
    static let currentPageIndicatorTintColor = UIColor(r: 247, g: 154, b: 27)
    static let currentPageIndicatorGreenTintColor = UIColor(r: 123, g: 147, b: 44)
    static let defaultGreenTintColor = UIColor(r: 132, g: 152, b: 66)
    
    
    //Gradient Colors
    static let gradientFirstColor = UIColor(r: 116, g: 116, b: 186)
    static let gradientSecondColor = UIColor(r: 77, g: 136, b: 194)
    
    //intro textcolor
    static let firstTextColor = UIColor(r: 95, g: 123, b: 255)
    static let secondTextColor = UIColor(r: 255, g: 95, b: 164)
    static let thirdTextColor = UIColor(r: 181, g: 95, b: 255)
    
    //button colors
    static let signinButtonBackgroundColor = UIColor(r: 255, g: 95, b: 168)
    
    //status bar colors
    static let loginStatusBarColor = UIColor(r: 215, g: 214, b: 213)
    static let signupStatusBarColor = UIColor(r: 65, g: 65, b: 65)
    
    //Fonts
    func loginFontLarge() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 30)!
        
    }
}

