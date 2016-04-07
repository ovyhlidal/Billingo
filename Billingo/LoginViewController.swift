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
        print("Login btn")
        
        self.firebase.authUser(username.text, password: password.text,
                               withCompletionBlock: { (error, auth) in
                                if error != nil {
                                    // There was an error logging in to this account
                                    
                                    self.onCreateAccount(sender)
                                    
                                } else {
                                    // We are now logged in
                                    self.performSegueWithIdentifier("showGroups", sender: nil)
                                    
                                }        })
        
        
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
