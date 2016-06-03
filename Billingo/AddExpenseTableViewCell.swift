//
//  AddExpenseTableViewCell.swift
//  Billingo
//
//  Created by Zuzana Plesingerova on 01.06.16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit

class AddExpenseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var isPaying: UISwitch!
    var isTrue: Bool = false
    
    @IBAction func statusChanged(sender: UISwitch) {
        self.isTrue = sender.on ? true : false
    }
}
    