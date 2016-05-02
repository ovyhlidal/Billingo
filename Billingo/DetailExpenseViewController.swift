//
//  DetailExpenseViewController1.swift
//  Billingo
//
//  Created by Zuzana Plesingerova on 02.05.16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit

class DetailExpenseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let reuseIdentifier: String = "ExpenseDetailCell"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var expenseName: UILabel!
    @IBOutlet weak var expenseCreateDate: UILabel!
    @IBOutlet weak var expenseCreator: UILabel!
    @IBOutlet weak var expenseCost: UILabel!
    
    var expense: Expense?
    
    @IBAction func backToDetailGroupView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expenseName.text = expense?.expenseName
        print(String(expense?.expenseCreateDate))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        expenseCreateDate.text = dateFormatter.stringFromDate((expense?.expenseCreateDate)!)
        expenseCreator.text = expense?.expenseCreator
        expenseCost.text = "Výdej: " + (expense?.cost)!
        self.tableView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Dlužníci"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (expense?.members.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ExpenseDetailTableViewCell
        let user: String = (self.expense?.members[indexPath.row])!
        cell.usrName.text = user
        let debt = ((Int((expense?.cost)!)! / Int((expense?.members.count)!)))
        //print(debt)
        cell.userDebt.text = "Dlh:" + String(debt)
        return cell
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

}
