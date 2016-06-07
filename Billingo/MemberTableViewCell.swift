//
//  MemberTableViewCell.swift
//  Billingo
//
//  Created by OndrejVyhlidal on 06/06/16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var memberNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
