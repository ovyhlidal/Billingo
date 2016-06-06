//
//  AddGroupViewController.swift
//  Billingo
//
//  Created by OndrejVyhlidal on 05/06/16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit

class AddGroupViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var addMemberTextField: UITextField!
    @IBOutlet weak var membersTableView: UITableView!
    var members = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onAdd(sender: AnyObject) {
        
        if (!addMemberTextField.text!.isEmpty) {
            // Create a NSCharacterSet of delimiters.
            let separators = NSCharacterSet(charactersInString: ":,; ")
            // Split based on characters.
            let parts = addMemberTextField.text!.componentsSeparatedByCharactersInSet(separators)
            
            for email in parts{
                
                print(email)
                
                if self .isValidEmail(email) {
                    print("valid email")
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
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        
    }
    
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }

}
