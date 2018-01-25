//
// UIImage+LetterAvatarKit.swift
//  Shades
//
//  Created by John Nik on 11/20/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

extension UIImage {
    /// Makes an letter-based avatar image using given configuration.
    ///
    /// - Parameters:
    ///     - configuration: The configuration that uses to draw a
    /// letter-based avatar image.
    ///
    /// - Returns: An instance of UIImage
    @objc(lak_makeLetterAvatarWithConfiguration:)
    static open func makeLetterAvatar(withConfiguration configuration: LetterAvatarBuilderConfiguration) -> UIImage? {
        return LetterAvatarBuilder().makeAvatar(withConfiguration: configuration)
    }
    
    /// Makes an letter-based avatar image using given username.
    ///
    /// - Parameters:
    ///     - username: The username that uses to draw a
    /// letter-based avatar image.
    ///
    /// - Returns: An instance of UIImage
    @objc(lak_makeLetterAvatarWithUsername:)
    static open func makeLetterAvatar(withUsername username: String?) -> UIImage? {
        let configuration = LetterAvatarBuilderConfiguration()
        configuration.username = username
        return LetterAvatarBuilder().makeAvatar(withConfiguration: configuration)
    }
    
    /// Makes an letter-based avatar image using given username and size.
    ///
    /// - Parameters:
    ///     - username: The username that uses to draw a
    /// letter-based avatar image.
    ///     - size: The avatar size.
    ///
    /// - Returns: An instance of UIImage
    @objc(lak_makeLetterAvatarWithUsername:size:)
    static open func makeLetterAvatar(withUsername username: String?, size: CGSize) -> UIImage? {
        let configuration = LetterAvatarBuilderConfiguration()
        configuration.username = username
        configuration.size = size
        return LetterAvatarBuilder().makeAvatar(withConfiguration: configuration)
    }
}
