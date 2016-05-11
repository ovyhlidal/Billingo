//
//  ViewController.swift
//  Billingo
//
//  Created by OndrejVyhlidal on 01/04/16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit
import Firebase

class GroupsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var addGroupButton: UIButton!
    
    var groups : Array = [Group]()
    let subview: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    let reuseIdentifier = "groupCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subview.startAnimating()
        subview.center = self.view.center
        self.view.addSubview(subview)
        loadAndDisplayGrubsFromServer()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGroupDetail" {
            if let indexPath = groupCollectionView!.indexPathForCell(sender as! GroupCollectionViewCell){
                var group: Group
                group = groups[indexPath.item]
                let nav = segue.destinationViewController as! UINavigationController
                let controller = nav.topViewController as! DetailGroupViewController
                controller.expenses = group.expenses
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
            memberText += member
            memberText += ", "
        }
        memberText.removeAtIndex(memberText.endIndex.predecessor().predecessor())   //remove last two letters ", "
        cell.groupMembers.text = memberText
        return cell
    }
    
    func getUserNameFromUserID(userID: String) -> String{
        let userRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/users/")
        var name = ""
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            name = (snapshot.value.objectForKey("\(userID)/name") as? String)!
        })
        return name
    }
}

extension GroupsViewController {
    func loadAndDisplayGrubsFromServer(){
        //TO DO: remove arbitrary load in final version from info.plist
        
        let selfUserRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/users/a031b1f3-4b7a-447b-8174-f6ac25b8a6e5/groups/")
        selfUserRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            for var groupValue in snapshot.children {
                if let groupID = snapshot.value[groupValue.key] as? String {
                    let groupRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/groups/\(groupID)")
                    let membersRef = groupRef.childByAppendingPath("members")
                    let expensesRef = groupRef.childByAppendingPath("expenses")
                        
                    var groupMembers:[String] = []
                    membersRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                        for var member in snapshot.children {
                            if let memberID = snapshot.value[member.key] as? String {
                                groupMembers.append(memberID)
                            }
                        }
                    })
                        
                    var groupExpenses:[Expense] = []
                    expensesRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
                        for var expense in snapshot.children {
                            
                            var payments:[Payment] = []
                            let paymentRef = expensesRef.childByAppendingPath("\(expense.key)/payments")
                            paymentRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
                                for payment in snapshot.children{
                                    if let cost = snapshot.value[payment.key] as? Double {
                                        payments.append(Payment(userID: payment.key, cost: cost ))
                                    }
                                }
                            })
                            
                            if let expenseName = snapshot.value["\(expense.key)/name"] as? String,
                            let expenseCreateDate = snapshot.value["\(expense.key)/createTime"] as? NSDate,
                            let expenseCreator = snapshot.value["\(expense.key)/payerUID"] as? String,
                            let cost = snapshot.value["\(expense.key)/totalCost"] as? String{
                                groupExpenses.append(Expense(expenseId: expense.key, expenseName: expenseName, expenseCreateDate: expenseCreateDate, expenseCreator: expenseCreator, cost: cost, payments: payments  ))
                            }
                        }
                    })
                    
                    var firstIteration = true
                    groupRef.observeEventType(.Value, withBlock: { snapshot in
                        if let groupName = snapshot.value["name"] as? String{
                            self.groups.append(Group(id: groupID , name: groupName, members: groupMembers, expenses: groupExpenses))
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.groupCollectionView.reloadData()
                        }
                        if firstIteration {
                            firstIteration = false
                            self.subview.stopAnimating()
                            self.subview.removeFromSuperview()
                        }
                    })
                }
            }
        
        }, withCancelBlock: { error in
            print(error.description)
        })
        
        
        /*let url = NSURL(string: "http://private-3a6f3-billingo1.apiary-mock.com/questions")!
        let request = NSMutableURLRequest(URL: url)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let response = response, data = data {
                //may check response
                var jsonRetString: [[String:AnyObject]]!
                do{
                    jsonRetString = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [[String:AnyObject]]
                }catch{
                    print(error)
                    return
                }
                if let groupJsonArray = jsonRetString as? [[String: AnyObject]] {
                    for groupJson in groupJsonArray {
                        if let groupID = groupJson["id"] as! String?,
                            let groupName = groupJson["name"] as! String?{
                            var groupMembers: [String] = []
                            for groupMember in groupJson["members"] as! [[String: AnyObject]]{
                                if let groupMemberString = groupMember["id"] as! String?{
                                    groupMembers.append(groupMemberString)
                                }
                            }
                            var groupExpenses: [Expense] = []
                            for groupExpense in groupJson["expenses"] as! [[String: AnyObject]]{
                                if let groupExpenseId = groupExpense["id"], let groupExpenseCreateDate = groupExpense["createDate"], let groupExpenseCreator = groupExpense["expenseCreator"],let groupExpenseName = groupExpense["expenseName"], let groupExpenseCost = groupExpense["cost"]{
                                    var groupExpenseMembers: [String] = []
                                    for groupExpenseMember in groupExpense["members"] as! [[String: AnyObject]]{
                                        if let expenseMemberString = groupExpenseMember["id"] as! String?{
                                            groupExpenseMembers.append(expenseMemberString)
                                        }
                                    }
                                    groupExpenses.append(Expense(expenseId: groupExpenseId as! String, expenseName: groupExpenseName as! String, expenseCreateDate: NSDate(timeIntervalSince1970: Double(groupExpenseCreateDate as! String)!),expenseCreator: groupExpenseCreator as! String, cost: groupExpenseCost as! String, members: groupExpenseMembers))
                                }
                            }
                            self.groups.append(Group(id: groupID , name: groupName, members: groupMembers, expenses: groupExpenses))
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.groupCollectionView.reloadData()
                    self.subview.stopAnimating()
                    self.subview.removeFromSuperview()
                }
            } else {
                print(error)
            }
        }
        task.resume()
        */
    }
}
