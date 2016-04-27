//
//  LoginViewController.swift
//  Billingo
//
//  Created by OndrejVyhlidal on 07/04/16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var keepMeLoggedIn: UISwitch!
    
    
    let firebase = Firebase(url: "https://glowing-heat-6814.firebaseio.com")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Welcome to Billingo"
        
        if self.alredyLoggedIn() {
            let defaults = NSUserDefaults.standardUserDefaults()
            
            let user = defaults.objectForKey("username") as! String
            let pw = defaults.objectForKey("password") as! String
            
            self.authenticateUserWithFirebase(user, password: pw)
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func onCreateAccount(sender: AnyObject) {
        
        
        let alertController = UIAlertController(title: "Create account", message: "You can create new account", preferredStyle: .Alert)
        
        let loginAction = UIAlertAction(title: "Create", style: .Default) { (_) in
            let loginTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            
            self.firebase.createUser(loginTextField.text, password: passwordTextField.text) { (error: NSError!) in
                
                if error == nil {
                    
                    self.firebase.authUser(loginTextField.text, password: passwordTextField.text, withCompletionBlock: { (error, auth) in
                        if(!auth.uid.isEmpty)
                        {
                            self.saveUser(loginTextField.text!, password:  passwordTextField.text!)
                            self.performSegueWithIdentifier("showGroups", sender: nil)
                        }
                    })
                }
            }
            
        }
        loginAction.enabled = false
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Email"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                loginAction.enabled = textField.text != ""
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        
        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) {
            // ...
        }
    }
    
    
    @IBAction func onLogin(sender: AnyObject) {
        
        self.authenticateUserWithFirebase(username.text!, password: password.text!)
    }
    
    func authenticateUserWithFirebase(username:String, password:String) -> Void {
        
        self.firebase.authUser(username, password: password,
                               withCompletionBlock: { (error, auth) in
                                if error != nil {
                                    // There was an error logging in to this account
                                    // handle this error better
                                    self.onCreateAccount(self)
                                    
                                } else {
                                    // We are now logged in
                                    self.saveUser(username, password: password)
                                    self.performSegueWithIdentifier("showGroups", sender: nil)
                                    
                                }        })

    }
    
    func saveUser(username: String, password: String){
        if keepMeLoggedIn.on {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(username, forKey: "username")
            defaults.setObject(password, forKey: "password")
            defaults.setObject(NSDate(), forKey: "lastLogin")
        }
    }
    
    
    func alredyLoggedIn() -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let user = defaults.objectForKey("username") as? String
        let pw = defaults.objectForKey("password") as? String
        
        
        if user != nil && pw != nil{
            if !(user!.isEmpty  && pw!.isEmpty) {
                print("successfull load of credentials")
                return true
            }
        }
        
        
        
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1
        self.firebase.observeAuthEventWithBlock { (authData) -> Void in
            // 2
            if authData != nil {
                // 3
                print("Logged in!");
                
                print(authData.description)
                // self.performSegueWithIdentifier("showGroups", sender: nil)
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
}
