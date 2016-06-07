//
//  Member.swift
//  Billingo
//
//  Created by Zuzana Plesingerova on 03.06.16.
//  Copyright © 2016 MU. All rights reserved.
//

import Foundation

class Member: NSObject{
    var memberName: String
    var memberID: String
  
    init(memberName:String, memberID:String) {
        self.memberName = memberName
        self.memberID = memberID
    }
    
    override init() {
        self.memberName = ""
        self.memberID = ""
    }
}