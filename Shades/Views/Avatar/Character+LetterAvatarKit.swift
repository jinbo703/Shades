//
// Character+LetterAvatarKit.swift
//  Shades
//
//  Created by John Nik on 11/20/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation

internal extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}
