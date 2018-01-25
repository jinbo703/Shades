//
//  UserCell.swift
//  Shades
//
//  Created by John Nik on 11/20/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Firebase



class UserCell: UITableViewCell {
    
    var user: ShadesUser? {
        
        didSet {
            
            guard  let user = user else {
                return
            }
            
            if let userName = user.userName {
                self.textLabel?.text = userName
            }
            
            if let imageUrl = user.photoUrl {
                self.profileImageView.loadImageUsingUrlString(urlString: imageUrl)
            } else {
                if let fullName = user.fullName {
                    self.profileImageView.image = UIImage.makeLetterAvatar(withUsername: fullName)
                }
            }
            
            if let memberSince = user.memberSince {
                self.detailTextLabel?.text = memberSince
            }
            
        }
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: (textLabel?.frame.height)!)
        
        detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
    }
    
    override func prepareForReuse() {
        self.textLabel?.text = ""
        self.profileImageView.image = nil
        self.detailTextLabel?.text = ""
        self.timeLabel.text = ""
        super.prepareForReuse()
        
    }
    
    lazy var profileImageView: CacheImageView = {
        
        let imageView = CacheImageView()
        imageView.image = UIImage(named: AssetName.alertIcon.rawValue)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapProfileImage)))
        return imageView
        
    }()
    
    @objc private func handleTapProfileImage(tapGesture: UITapGestureRecognizer) {
        
    }
    
    let timeLabel: UILabel = {
        
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.more.rawValue)
        button.setImage(image, for: .normal)
        button.tintColor = StyleGuideManager.firstTextColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.textLabel?.font = UIFont(name: "VisbyRoundCF-Bold", size: 20)
        self.detailTextLabel?.font = UIFont(name: "VisbyRoundCF-Medium", size: 15)
        
        addSubview(profileImageView)
        addSubview(moreButton)
        addSubview(timeLabel)
        
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        moreButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        moreButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        moreButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        
        timeLabel.rightAnchor.constraint(equalTo: moreButton.leftAnchor, constant: -5).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

