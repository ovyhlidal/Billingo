//
//  Group.swift
//  Billingo
//
//  Created by OndrejVyhlidal on 27/04/16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit

class Group: NSObject {
    var id = "noID"
    var name = "noName"
    var members: [Member]
    var expenses:[Expense]
    
    init(id:String, name:String, members: [Member], expenses: [Expense]) {
        self.id = id
        self.name = name
        self.members = members
        self.expenses = expenses
    }
}
