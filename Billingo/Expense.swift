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
    var expenseCreatorName: String
    var expenseCreatorID: String
    var cost: Double
    var payments: [Payment]
    
    init(expenseId: String, expenseName: String, expenseCreateDate: NSDate, expenseCreatorName: String, expenseCreatorID: String,cost: Double, payments: [Payment]) {
        self.expenseId = expenseId
        self.expenseName = expenseName
        self.expenseCreateDate = expenseCreateDate
        self.expenseCreatorName = expenseCreatorName
        self.expenseCreatorID = expenseCreatorID
        self.cost = cost
        self.payments = payments
    }
}