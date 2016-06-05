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
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let firebase = Firebase(url: "https://glowing-heat-6814.firebaseio.com")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Welcome to Billingo"
        
        self.loadingView.hidden = true
        self.loadingView.alpha = 0
        self.activityIndicator.stopAnimating()
        
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
            let nameTextField = alertController.textFields![0] as UITextField
            let loginTextField = alertController.textFields![1] as UITextField
            let passwordTextField = alertController.textFields![2] as UITextField
            
            self.firebase.createUser(loginTextField.text, password: passwordTextField.text) { (error: NSError!) in
                
                
                self.showLoading()
                if error == nil {
                    
                    self.firebase.authUser(loginTextField.text, password: passwordTextField.text, withCompletionBlock: { (error, auth) in
                        if(!auth.uid.isEmpty)
                        {
                            self.saveUser(loginTextField.text!, password:  passwordTextField.text!)
                            self.performSegueWithIdentifier("showGroups", sender: nil)
                            self.hideLoading()
                        }
                    })
                    self.saveNewUser(nameTextField.text!, email: loginTextField.text!)
                }
                else
                {
                    let alertControllerSimple = UIAlertController(title: "Error", message: "There is a problem with connection", preferredStyle: .Alert)
                    
                    
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        // ...
                    }
                    alertControllerSimple.addAction(OKAction)
                    
                    self.presentViewController(alertControllerSimple, animated: true) {
                        // ...
                    }
                    // handle errors!!
                    
                }
            }
            
        }
        loginAction.enabled = false
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
        }
        
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
        
        self.showLoading()
        
        self.authenticateUserWithFirebase(username.text!, password: password.text!)
    }
    
    func authenticateUserWithFirebase(username:String, password:String) -> Void {
        
        self.firebase.authUser(username, password: password,
                               withCompletionBlock: { (error, auth) in
                                if error != nil {
                                    // There was an error logging in to this account
                                    // handle this error better
                                    print(error)
                                    
                                    if let errorCode = FAuthenticationError(rawValue: error.code) {
                                        switch (errorCode) {
                                        case .UserDoesNotExist:
                                            self.onCreateAccount(self)
                                        case .InvalidEmail:
                                            print("Handle invalid email")
                                            self .showError("Invalid email")
                                        case .InvalidPassword:
                                            print("Handle invalid password")
                                            self .showError("Invalid pasword")
                                        default:
                                            print("Handle default situation")
                                        }
                                    }
                                   
                                    
                                } else {
                                    // We are now logged in
                                    self.hideLoading()
                                    self.saveUser(username, password: password)
                                    self.performSegueWithIdentifier("showGroups", sender: nil)
                                    
                                }        })

    }
    
    
    func showError(errorMessage :String) -> Void {
        let alertControllerSimple = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self .hideLoading()
        }
        
        alertControllerSimple.addAction(OKAction)
        
        self.presentViewController(alertControllerSimple, animated: true) {
            // ...
        }
        // handle errors!!

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
            else
            {
                // problem occured
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        let name = "Pattern~\(self.title!)"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if segue.identifier == "showGroups" {
            let nav = segue.destinationViewController as! UINavigationController
            let controller = nav.topViewController as! GroupsViewController
            controller.currentUser = firebase.(). self.firebase.getAuth
        }*/
    }
    
    func saveNewUser(name:String, email:String){
        let usersRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/users/")
        let myID = usersRef.authData.uid
        let jsonUser = ["fullname":"\(name)", "email":"\(email)"]
        let newUser = usersRef.childByAppendingPath("\(myID)")
        newUser.setValue(jsonUser)
    }
    
    func showLoading() -> Void {
        self.loadingView.alpha = 0.0
        self.loadingView.hidden = false
        
        UIView .animateWithDuration(1.0, animations: { 
            self.loadingView.alpha = 1.0
            }) { (true) in
                self.activityIndicator.startAnimating()
        }
    }
    
    func hideLoading() -> Void {
        UIView .animateWithDuration(1.0, animations: { 
            self.loadingView.alpha = 0.0
            }) { (true) in
                self.loadingView.hidden = true
                self.activityIndicator.stopAnimating()
        }
        
    }
    
}
