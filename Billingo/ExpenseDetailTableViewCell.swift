//
//  DetailExpenseTableViewCell1.swift
//  Billingo
//
//  Created by Zuzana Plesingerova on 02.05.16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit

class ExpenseDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usrName: UILabel!
    @IBOutlet weak var userDebt: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
