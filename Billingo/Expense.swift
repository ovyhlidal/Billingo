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
    var payments: [Payment]
    
    init(expenseId: String, expenseName: String, expenseCreateDate: NSDate, expenseCreator: String,cost: String, payments: [Payment]) {
        self.expenseId = expenseId
        self.expenseName = expenseName
        self.expenseCreateDate = expenseCreateDate
        self.expenseCreator = expenseCreator
        self.cost = cost
        self.payments = payments
    }
}