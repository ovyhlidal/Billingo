//
//  Expense.swift
//  Billingo
//
//  Created by Zuzana Plesingerova on 28.04.16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit

class Expense: NSObject {
    var expenseId: String
    var expenseName: String
    var expenseCreateDate: NSDate
    var expenseCreator: String
    var cost: String
    var members: [String]
    
    init(expenseId: String, expenseName: String, expenseCreateDate: NSDate, expenseCreator: String,cost: String, members: [String]) {
        self.expenseId = expenseId
        self.expenseName = expenseName
        self.expenseCreateDate = expenseCreateDate
        self.expenseCreator = expenseCreator
        self.cost = cost
        self.members = members
    }
}