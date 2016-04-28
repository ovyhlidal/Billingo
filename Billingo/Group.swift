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
    
    override init() {
        super.init()
        id = "Testing ID"
        name = "name Test"
        members = ["test Jan", "test Peter", "test Dory"]
    }
    
    init(setId:String, setName:String, setMembers:[String]) {
        super.init()
        id = setId
        name = setName
        members = setMembers
    }
}
