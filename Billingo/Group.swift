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
    var members:[String] = []
    var expenses:[Expense] = []
    
    override init() {
        super.init()
        id = "Testing ID"
        name = "name Test"
        members = ["test Jan", "test Peter", "test Dory"]
    }
    
    init(id:String, name:String, members:[String], expenses: [Expense]) {
        super.init()
        self.id = id
        self.name = name
        self.members = members
        self.expenses = expenses
    }
}
