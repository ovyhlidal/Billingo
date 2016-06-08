//
//  AddGroupViewController.swift
//  Billingo
//
//  Created by OndrejVyhlidal on 05/06/16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit
import Firebase

class AddGroupViewController: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var addMemberTextField: UITextField!
    @IBOutlet weak var membersTableView: UITableView!
    let firebase = Firebase(url: Constants.baseURL + "users/")
    var members:NSMutableArray = []
    var validMembers:NSMutableArray = []
    var groupMembers = [String]()
    
    var myID = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        members = NSMutableArray()
        groupMembers = [String]()
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreateGroup(sender: AnyObject) {
        
        if self.groupNameTextField.text!.characters.count > 0 {
            if self.validMembers.count > 0 {
                
                // get array of refs for users
                let usersRef = Firebase(url: Constants.baseURL +  "users/")
                let myEmail = NSUserDefaults.standardUserDefaults().stringForKey("username") as String!
                usersRef.queryOrderedByChild("email").queryEqualToValue(myEmail).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                    
                    self.groupMembers.append(snapshot.key)
                    self.saveNewGroup(self.groupNameTextField.text!, membersID: self.groupMembers)
                })
                
            }
            else
            {
                // alert Add some members!
            }
            
        }
        else
        {
            // alert Fill Name of Group!
        }
    }
    
    @IBAction func onAdd(sender: AnyObject) {
        
        if (!addMemberTextField.text!.isEmpty) {
            // Create a NSCharacterSet of delimiters.
            
            var originalText = addMemberTextField.text!
            
            
            let separators = NSCharacterSet(charactersInString: ":,; ")
            // Split based on characters.
            let parts = addMemberTextField.text!.componentsSeparatedByCharactersInSet(separators)
            
            for email in parts{
                if self .isValidEmail(email) {
                    
                    let usersRef = Firebase(url: Constants.baseURL +  "users/")
                    usersRef.queryOrderedByChild("email").queryEqualToValue(email).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
                        print("snapshot", snapshot.description)
                        
                        if let name = snapshot.value["fullname"] as? String{
                            self.groupMembers.append(snapshot.key)
                            self.validMembers.addObject(Member(memberName: name, memberID: snapshot.key, memberEmail: email))
                            
                            self.membersTableView.reloadData()
                            
                            self.addMemberTextField.text = "" // originalText.stringByReplacingOccurrencesOfString(email, withString: "")
                        }
                        
                        
                        }, withCancelBlock: { error in
                            print("Tady je chyba!")
                            print(error.description)
                    })
                }
            }
            
            
            
        }
        
    }
    
    func saveNewExpense(groupID:String, payments:[String:Double], payerID:String, reason:String, time:NSDate, totalCost:Double){
        let expensesRef = Firebase(url: Constants.baseURL + "groups/\(groupID)/expenses/")
        let jsonExpense = ["reason":"\(reason)", "payer":"\(payerID)", "createTime":(Int.init(time.timeIntervalSince1970)), "totalCost":(totalCost)]
        let newExpense = expensesRef.childByAutoId()
        newExpense.setValue(jsonExpense)
        newExpense.childByAppendingPath("payments").setValue(payments)
    }
    
    func saveNewGroup(name:String, membersID:[String]){
        let groupsRef = Firebase(url:  Constants.baseURL + "groups/")
        let jsonGroup = ["name":"\(name)"]
        let newGroup = groupsRef.childByAutoId()
        newGroup.setValue(jsonGroup)
        
        let groupMembers = newGroup.childByAppendingPath("members")
        
        let usersRef = Firebase(url:  Constants.baseURL + "users/")
        
        for memberID in membersID {
            let userRef = usersRef.childByAppendingPath(memberID)
            let userGroupRef = userRef.childByAppendingPath("groups")
            let newUserGroupRef = userGroupRef.childByAutoId()
            let addMember = groupMembers.childByAutoId()
            addMember.setValue(memberID)
            newUserGroupRef.setValue(addMember.key)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return validMembers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell") as? MemberTableViewCell!
        
        let member = validMembers[indexPath.row] as! Member
        cell!.memberNameLabel.text = member.memberName + "-" + member.memberEmail
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
}
