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
    var memberEmail: String
  
    init(memberName:String, memberID:String, memberEmail:String) {
        self.memberName = memberName
        self.memberID = memberID
        self.memberEmail = memberEmail
    }
    
    
    init(memberName:String, memberID:String) {
        self.memberName = memberName
        self.memberID = memberID
        self.memberEmail = ""
    }

    override init() {
        self.memberName = ""
        self.memberID = ""
        self.memberEmail = ""
    }
}