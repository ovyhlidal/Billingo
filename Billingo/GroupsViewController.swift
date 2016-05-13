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
    
    override func viewWillAppear(animated: Bool) {
        let name = "Pattern~\("GroupsViewController")"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
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
        for member in groups[indexPath.item].membersNames {
            memberText += member
            memberText += ", "
        }
        if(memberText.characters.count > 2){
            memberText.removeAtIndex(memberText.endIndex.predecessor().predecessor())   //remove last two letters ", "
        }
        cell.groupMembers.text = memberText
        return cell
    }
    
    func getUserNameFromUserID(userID: String) -> String{
        let userRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/users/")
        var name = ""
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            name = (snapshot.value.objectForKey("\(userID)/fullname") as? String)!
        })
        return name
    }
    
    func loadAndDisplayGroupsNames(){
        let MyID = "a031b1f3-4b7a-447b-8174-f6ac25b8a6e5"
        let selfUserRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/users/\(MyID)/groups/")
        selfUserRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            if let groupID = snapshot.value as? String {
                let groupRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/groups/\(groupID)")
                let groupMembersNames:[String] = []
                let groupMembersIDs:[String] = []
                let groupExpenses:[Expense] = []
                
                var firstIteration = true
                groupRef.observeEventType(.Value, withBlock: { snapshot in
                    if let groupName = snapshot.value["name"] as? String{
                        let group = Group(id: groupID , name: groupName, membersNames: groupMembersNames, membersIDs: groupMembersIDs, expenses: groupExpenses)
                        self.groups.append(group)
                        let GroupIndex = self.groups.indexOf(group)
                        self.loadAndDisplayGroupMembers(GroupIndex)
                        self.loadGroupExpenseAndDisplaySum(GroupIndex)
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
        })
        
    }
    
    func loadAndDisplayGroupMembers(groupIndex:Int?){
        let group = groups[groupIndex!]
        print(group.id)
        let membersRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/groups/\(group.id)/members")
        membersRef.observeEventType(.ChildAdded, withBlock: { snapshot in
            if let memberID = snapshot.value as? String {
                group.membersIDs.append(memberID)
                let userRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/users/\(memberID)/fullname")
                userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    let name = (snapshot.value as? String)!
                    group.membersNames.append(name)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.groupCollectionView.reloadData()
                    }
                })
            }
        })
    }
    
    func loadGroupExpenseAndDisplaySum(groupIndex:Int?){
        print ("here")
        let group = groups[groupIndex!]
        let expensesRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/groups/\(group.id)/expenses/")
        expensesRef.observeEventType(.ChildAdded, withBlock: {snapshot in
        
            let payments:[Payment] = []
            
            if let expenseName = snapshot.value["reason"] as? String,
            let expenseCreatorID = snapshot.value["payerUID"] as? String,
            let cost = snapshot.value["totalCost"] as? Double,
            let expenseCreateDate = snapshot.value["createTime"] as? Double{
                let userRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/users/\(expenseCreatorID)/fullname")
                userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if let expenseCreatorName = snapshot.value as? String{
                        let expense = Expense(expenseId: snapshot.key, expenseName: expenseName, expenseCreateDate: NSDate(timeIntervalSince1970: expenseCreateDate), expenseCreatorName: expenseCreatorName, expenseCreatorID:  expenseCreatorID, cost: cost, payments: payments  )
                        self.groups[groupIndex!].expenses.append(expense)
                        self.loadPaymants(groupIndex, expenseIndex: self.groups[groupIndex!].expenses.indexOf(expense))
                        dispatch_async(dispatch_get_main_queue()) {
                            self.groupCollectionView.reloadData()
                        }
                    }
                })
            }
        })
    }
    
    func loadPaymants(groupIndex:Int?, expenseIndex:Int?){
        let group = groups[groupIndex!]
        let expense = group.expenses[expenseIndex!]
        let paymentRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/groups/\(group.id)/expenses/\(expense.expenseId)/payments")
        paymentRef.observeEventType(.ChildAdded, withBlock: {snapshot in
            if let cost = snapshot.value[snapshot.key] as? Double {
                let userRef = Firebase(url: "https://glowing-heat-6814.firebaseio.com/users/\(snapshot.key)/fullname")
                userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if let name = snapshot.value as? String{
                        group.expenses[expenseIndex!].payments.append(Payment(userID: snapshot.key,userName: name, cost: cost ))
                    }
                })
            }
            
        })
    }
}



extension GroupsViewController {
    func loadAndDisplayGrubsFromServer(){
        //TO DO: remove arbitrary load in final version from info.plist
        
        loadAndDisplayGroupsNames()

    }
}
