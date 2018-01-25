//
// String+LetterAvatarKit.swift
//  Shades
//
//  Created by John Nik on 11/20/17.
//  Copyright © 2017 johnik703. All rights reserved.
//
import Foundation

extension String {
    /// The the first element of the collection.
    ///
    /// If the collection is empty, the value of this property is `nil`.
    var first: Character? {
        get {
            if isEmpty {
                return nil
            }
            return self[index(startIndex, offsetBy: 0)]
        }
    }
    
}
