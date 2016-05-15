//
//  payment.swift
//  Billingo
//
//  Created by Matej Minarik on 11/05/16.
//  Copyright © 2016 MU. All rights reserved.
//

import Foundation

class Payment: NSObject{
    var userID:String
    var userName:String
    var cost:Double
    override init() {
        userID = "0000000"
        userName = "hoza chudobny"
        cost = 3.141592654
    }
    init(userID:String, userName:String, cost:Double) {
        self.userID = userID
        self.userName = userName
        self.cost = cost
    }
}