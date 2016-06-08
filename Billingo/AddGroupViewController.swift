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
    
    @IBOutlet weak var addMemberTextField: UITextField!
    @IBOutlet weak var membersTableView: UITableView!
    let firebase = Firebase(url: Constants.baseURL + "users/")
    var members:NSMutableArray = []
    var validMembers:NSMutableArray = []
    var groupMembers = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        members = NSMutableArray()
        // Do any additional setup after loading the view.
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                        print("snapshot block")
                        
                        if let name = snapshot.value["fullname"] as? String{
                            self.groupMembers.append(name)
                            self.validMembers.addObject(Member(memberName: name, memberID: email))
                            self.membersTableView.reloadData()
                            
                            self.addMemberTextField.text = "" // originalText.stringByReplacingOccurrencesOfString(email, withString: "")
                        }
                        else
                        {
                            print("snapshot ale jinej protoze neni full name")
                        }
                        
                        
                        }, withCancelBlock: { error in
                            print("Tady je chyba!")
                            print(error.description)
                    })

                   
            
                }
            }
            
           
            
        }
        
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
//    usersRef.queryOrderedByChild("email").queryEqualToValue(email).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
//    if let name = snapshot.value["fullname"] as? String{
//    textField.text = name
//    }
//    })
//}
//    func getAllUsers() -> Void {
//        let userRef = Firebase(url: Constants.baseURL + "users/")
//        
//        userRef.observeEventType(.ChildAdded, withBlock: { snapshot in
//
//            var member = Member()
//            if let name = snapshot.value["fullname"] as? String {
//                member.memberName = name
//            }
//            
//            if let email = snapshot.value["email"] as? String{
//               member.memberID = email
//            }
//            
//            self.members.addObject(member)
//            print(self.members)
//        })
//        
//    
//    }
    
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
        cell!.memberNameLabel.text = member.memberName + "-" + member.memberID
        
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
}
