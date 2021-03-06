//
//  AddExpenseViewController.swift
//  Billingo
//
//  Created by Zuzana Plesingerova on 01.06.16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit
import Firebase

class AddExpenseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var groupID: String?
    var payerID: String?
    var groupMembers: [Member]?
    @IBOutlet weak var expenseName: UITextField!
    @IBOutlet weak var expenseCost: UITextField!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        var indexOfMyId: Int = 0
        for index in 0 ..< groupMembers!.count {
            if groupMembers![index].memberID == payerID {
                indexOfMyId = index
                break
            }
        }
        groupMembers?.removeAtIndex(indexOfMyId)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addExpense(sender: AnyObject) {
        if self.expenseName.text!.characters.count > 0 {
            if self.expenseCost.text!.characters.count > 0 {
                let expenseCostAdapted = expenseCost.text!.stringByReplacingOccurrencesOfString(",", withString: ".")
                
                var count: Int = 0
                for i in expenseCostAdapted.characters {
                    if i == "." {
                        count += 1
                    }
                }
                if count <= 1 {
                    var reason: String
                    var totalCost: Double
                    
                    reason = expenseName.text!
                    totalCost = Double.init(expenseCostAdapted)!
                    let time: NSDate = NSDate()
                    var count: Int = 0
                    
                    var payments: [String:Double] = [:]
                    var list = [AddExpenseTableViewCell]()
                    
                    for section in 0 ..< 1 {
                        let rowCount = tableView.numberOfRowsInSection(section)
                        //var list = [AddExpenseTableViewCell]()
                        
                        for row in 0 ..< rowCount {
                            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) as! AddExpenseTableViewCell
                            list.append(cell)
                        }
                        
                        for cell in list {
                            if cell.isTrue {
                                count += 1
                                //payments[cell.name.text!] = String.init(totalCost/(Double.init(count) + 1))
                                //payments["a031b1f3-4b7a-447b-8174-f6ac25b8a6e5"] = totalCost/(Double.init(count) + 1)
                            }
                        }
                    }
                    
                    var index: Int = 0
                    payments[payerID!] = totalCost/(Double.init(count + 1))
                    for cell in list {
                        if cell.isTrue {
                            if cell.name.text == groupMembers![index].memberName {
                                payments[groupMembers![index].memberID] = totalCost/(Double.init(count + 1))
                            }
                        }
                        index += 1
                    }
                    //let paymentCost = String.init(totalCost/Double.init(count))
                    
                    //let payment = Payment()
                    //let payment1 = Payment()
                    saveNewExpense(groupID!, payments: payments, payerID: payerID!, reason: reason, time: time, totalCost: totalCost)
                    self.navigationController!.popViewControllerAnimated(true)
                }
                else {
                    self.showError("Wrong number format!")
                    expenseCost.text = ""
                }
            }
            else {
                self.showError("You need to add cost!")
            }
        }
        else {
            self.showError("You need to add name of expense!")
        }
    }
    
    func saveNewExpense(groupID:String, payments:[String:Double], payerID:String, reason:String, time:NSDate, totalCost:Double){
        let expensesRef = Firebase(url: Constants.baseURL + "groups/\(groupID)/expenses/")
        let jsonExpense = ["reason":"\(reason)", "payer":"\(payerID)", "createTime":(Int.init(time.timeIntervalSince1970)), "totalCost":(totalCost)]
        let newExpense = expensesRef.childByAutoId()
        newExpense.setValue(jsonExpense)
        newExpense.childByAppendingPath("payments").setValue(payments)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMembers!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddExpenseCell", forIndexPath: indexPath) as! AddExpenseTableViewCell
        let member = groupMembers![indexPath.row]
        /*if !(member.memberID == payerID!) {
            cell.name.text = member.memberName
        }*/
        cell.name.text = member.memberName
        return cell
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
