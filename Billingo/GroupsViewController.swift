//
//  ViewController.swift
//  Billingo
//
//  Created by OndrejVyhlidal on 01/04/16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit

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
}

extension GroupsViewController {
    func loadAndDisplayGrubsFromServer(){
        //TO DO: remove arbitrary load in final version from info.plist
        let url = NSURL(string: "http://private-3a6f3-billingo1.apiary-mock.com/questions")!
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
    }
}
