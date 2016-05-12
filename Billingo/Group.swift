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
    var membersNames:[String] = []
    var membersIDs:[String] = []
    var expenses:[Expense] = []
    
    override init() {
        super.init()
        id = "Testing ID"
        name = "name Test"
        membersNames = ["test Jan", "test Peter", "test Dory"]
        
    }
    
    init(id:String, name:String, membersNames:[String], membersIDs:[String], expenses: [Expense]) {
        super.init()
        self.id = id
        self.name = name
        self.membersNames = membersNames
        self.membersIDs = membersIDs
        self.expenses = expenses
    }
}
