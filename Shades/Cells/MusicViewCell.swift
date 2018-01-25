//
//  MusicViewCell.swift
//  Shades
//
//  Created by John Nik on 25/11/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class MusicViewCell: UITableViewCell {
    
    @IBOutlet var lbTitle:UILabel!
    @IBOutlet var lbDesc:UILabel!
    @IBOutlet var btnDel:UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnDel.layer.cornerRadius = 5
        btnDel.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
