//
//  SearchViewCell.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class SearchViewCell: UITableViewCell {
    
    @IBOutlet var imgUserPhoto:UIImageView!
    @IBOutlet var lbUsername:UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgUserPhoto.layer.cornerRadius = imgUserPhoto.frame.size.width/2
        imgUserPhoto.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
