//
//  ViewController.swift
//  Billingo
//
//  Created by OndrejVyhlidal on 01/04/16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit
import Firebase

struct Constants {
    static let baseURL = "https://billingo.firebaseio.com/"
}

class GroupsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var addGroupButton: UIButton!
    var myID: String?
    var groups : Array = [Group]()
    let subview: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    let reuseIdentifier = "groupCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subview.startAnimating()
        subview.center = self.view.center
        self.view.addSubview(subview)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func showMenu(sender: MenuButton) {
        let alert = UIAlertController(title: "Billingo", message: "", preferredStyle: .ActionSheet) // 1
        let firstAction = UIAlertAction(title: "About application", style: .Default) { (alert: UIAlertAction!) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string:"https://www.billingo.hu")!)
        } // 2
        
        let secondAction = UIAlertAction(title: "Logout", style: .Default) { (alert: UIAlertAction!) -> Void in
            let serverRef = Firebase(url: Constants.baseURL)
            NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
            NSUserDefaults.standardUserDefaults().removeObjectForKey("password")
            serverRef.unauth()
            self.navigationController?.popViewControllerAnimated(true)
        } // 3
        
        alert.addAction(firstAction) // 4
        alert.addAction(secondAction) // 5
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion:nil) // 6
        
    }
    
    override func viewWillAppear(animated: Bool) {
        let name = "Pattern~\("GroupsViewController")"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        loadAndDisplayGrubsFromServer()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGroupDetail" {
            if let indexPath = groupCollectionView!.indexPathForCell(sender as! GroupCollectionViewCell){
                var group: Group
                group = groups[indexPath.item]
                let controller = segue.destinationViewController as! DetailGroupViewController
                controller.expenses = group.expenses
                controller.groupMembers = group.members
                controller.groupID = group.id
                controller.group = group
                controller.myID = self.myID!
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        // handle user logout -> delete from nsuser defaults all records!
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("password")
        
        self.navigationController?.popViewControllerAnimated(true)
       
    }
    
    @IBAction func onAddGroup(sender: AnyObject) {
        
        
    }
    
    //there will be just one section
    func numberOfSectionsInCollectionView(collectionView:UICollectionView) -> Int {
        return 1
    }
    
    //number of groups for current user
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GroupCollectionViewCell
        // Configure the cell
        cell.groupName.text = groups[indexPath.item].name
        var memberText = ""
        for member in groups[indexPath.item].members {
            memberText += member.memberName
            memberText += ", "
        }
        
        if(memberText.characters.count > 2){
            memberText.removeAtIndex(memberText.endIndex.predecessor().predecessor())   //remove last two letters ", "
        }
        
        cell.groupMembers.text = memberText
        var balanceSum = 0.0
        if let myid = myID as String!{
            for expense in groups[indexPath.item].expenses {
                if(expense.expenseCreatorID == myid){
                    for payment in expense.payments {
                        if payment.userID != myid {
                            balanceSum += payment.cost
                        }
                    }
                }else{
                    for payment in expense.payments {
                        if payment.userID == myid {
                            balanceSum -= payment.cost
                        }
                    }
                }
            }
            if balanceSum < 0 {
                cell.groupInfo.textColor = UIColor.redColor()
            }else{
                cell.groupInfo.textColor = UIColor.blackColor()
            }
            let balanceSumAdapted = String(format: "%.2f", balanceSum)
            cell.groupInfo.text = "Your balance: \(balanceSumAdapted)"
        }
        return cell
    }
    
    func getUserNameFromUserID(userID: String) -> String{
        let userRef = Firebase(url: Constants.baseURL + "users/")
        var name = ""
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            name = (snapshot.value.objectForKey("\(userID)/fullname") as? String)!
        })
        return name
    }
    
    func loadAndDisplayGroupsNames(){
        let serverRef = Firebase(url: Constants.baseURL)
        myID = serverRef.authData.uid
        if(myID != nil){
            let selfUserRef = serverRef.childByAppendingPath("users/\(myID!)/groups/")
            selfUserRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if snapshot.value is NSNull {
                    self.subview.stopAnimating()
                    self.subview.removeFromSuperview()
                    
                    self.showError("We did not find any groups for you")
                }
            })
            
            selfUserRef.observeEventType(.ChildAdded, withBlock: { snapshot in
                if(snapshot.value is NSNull){           //if there is no group for this user stop loading
                    self.subview.stopAnimating()
                    self.subview.removeFromSuperview()
                    self.showError("We did not find any groups for you.")
                }else{
                    if let groupID = snapshot.value as? String {
                        let groupRef = Firebase(url:  Constants.baseURL + "groups/\(groupID)")
                        let groupMembers: [Member] = []
                        let groupExpenses:[Expense] = []
                        
                        var firstIteration = true
                        groupRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                            if let groupName = snapshot.value["name"] as? String{
                                let group = Group(id: groupID , name: groupName, members: groupMembers, expenses: groupExpenses)
                                var isNew = true
                                for group in self.groups {
                                    if(group.id == groupID){
                                        isNew = false
                                    }
                                }
                                if(isNew){
                                    self.groups.append(group)
                                    let GroupIndex = self.groups.indexOf(group)
                                    self.loadAndDisplayGroupMembers(GroupIndex)
                                    self.loadGroupExpenseAndDisplaySum(GroupIndex)
                                }
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.groupCollectionView.reloadData()
                                if firstIteration {
                                    firstIteration = false
                                    self.subview.stopAnimating()
                                    self.subview.removeFromSuperview()
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    
    func loadAndDisplayGroupMembers(groupIndex:Int?){
        let group = groups[groupIndex!]
        let membersRef = Firebase(url:  Constants.baseURL + "groups/\(group.id)/members")
        membersRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            if let memberID = snapshot.value as? String {
                let userRef = Firebase(url:  Constants.baseURL + "users/\(memberID)/fullname")
                userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    let name = (snapshot.value as? String)!
                    var newMember = true
                    for member in group.members {
                        if(member.memberID == memberID){
                            newMember = false
                        }
                    }
                    if(newMember){
                        group.members.append(Member(memberName: name, memberID: memberID))
                        dispatch_async(dispatch_get_main_queue()) {
                            self.groupCollectionView.reloadData()
                        }
                    }
                })
            }
        })
    }
    
    func loadGroupExpenseAndDisplaySum(groupIndex:Int?){
        let group = groups[groupIndex!]
        let expensesRef = Firebase(url:  Constants.baseURL + "groups/\(group.id)/expenses/")
        expensesRef.observeEventType(.ChildAdded, withBlock: {snapshot in
            let payments:[Payment] = []
            let expenseID = snapshot.key
            if let expenseName = snapshot.value["reason"] as? String,
            let expenseCreatorID = snapshot.value["payer"] as? String,
            let cost = snapshot.value["totalCost"] as? Double,
            let expenseCreateDate = snapshot.value["createTime"] as? Double{
                let userRef = Firebase(url:  Constants.baseURL + "users/\(expenseCreatorID)/fullname")
                userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if let expenseCreatorName = snapshot.value as? String{
                        let expense = Expense(expenseId: expenseID, expenseName: expenseName, expenseCreateDate: NSDate(timeIntervalSince1970: expenseCreateDate), expenseCreatorName: expenseCreatorName, expenseCreatorID:  expenseCreatorID, cost: cost, payments: payments)
                        var newExpense = true
                        for oldExpenses in self.groups[groupIndex!].expenses {
                            if(oldExpenses.expenseId == expense.expenseId){
                                newExpense = false
                            }
                        }
                        if(newExpense){
                            self.groups[groupIndex!].expenses.append(expense)
                            self.loadPaymants(groupIndex, expenseIndex: self.groups[groupIndex!].expenses.indexOf(expense))
                            dispatch_async(dispatch_get_main_queue()) {
                                self.groupCollectionView.reloadData()
                            }
                        }
                    }
                })
            }
        })
    }
    
    func loadPaymants(groupIndex:Int?, expenseIndex:Int?){
        let group = groups[groupIndex!]
        let expense = group.expenses[expenseIndex!]
        let paymentRef = Firebase(url:  Constants.baseURL + "groups/\(group.id)/expenses/\(expense.expenseId)/payments")
        paymentRef.observeEventType(.ChildAdded, withBlock: {snapshot in
            if let cost = snapshot.value as? Double{
                let userID = snapshot.key
                let userRef = Firebase(url:  Constants.baseURL + "users/\(snapshot.key)/fullname")
                userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if let name = snapshot.value as? String{
                        var newPayment = true
                        for payment in group.expenses[expenseIndex!].payments {
                            if((payment.userID == userID) && (payment.cost == cost) && (payment.userName == name)){
                                newPayment = false
                            }
                        }
                        if(newPayment){
                            group.expenses[expenseIndex!].payments.append(Payment(userID: userID,userName: name, cost: cost ))
                            dispatch_async(dispatch_get_main_queue()) {
                                self.groupCollectionView.reloadData()
                            }
                        }
                    }
                })
            }
            
        })
    }
    
    func saveNewGroup(name:String, membersID:[String]){
        let groupsRef = Firebase(url:  Constants.baseURL + "groups/)")
        let jsonGroup = ["name":"\(name)"]
        let newGroup = groupsRef.childByAutoId()
        newGroup.setValue(jsonGroup)
        
        for memberID in membersID {
            let addMember = newGroup.childByAutoId()
            addMember.setValue(memberID)
        }
    }
    
    func getNameFromEmail(email:String, textField:UITextField){
        let usersRef = Firebase(url: Constants.baseURL + "users/")
        usersRef.queryOrderedByChild("email").queryEqualToValue(email).observeSingleEventOfType(.ChildAdded, withBlock: {snapshot in
            if let name = snapshot.value["fullname"] as? String{
                textField.text = name
            }
        })
    }
    
    func showError(errorMessage :String) -> Void {
        let alertControllerSimple = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            
        }
        
        alertControllerSimple.addAction(OKAction)
        
        self.presentViewController(alertControllerSimple, animated: true) {
            // ...
        }
        
        
    }
    
}



extension GroupsViewController {
    func loadAndDisplayGrubsFromServer(){
        //TO DO: remove arbitrary load in final version from info.plist
        
        loadAndDisplayGroupsNames()

    }
}
