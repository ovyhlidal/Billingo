//
//  DerailGroupTableViewController.swift
//  Billingo
//
//  Created by Zuzana Plesingerova on 28.04.16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit


class DetailGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let reuseIdentifier = "ExpenseCell"
    let reuseIdentifierForSegue = "showExpenseDetail"
    var expenses: Array = [Expense]()
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backToGroupsView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == reuseIdentifierForSegue {
            if let indexPath = self.tableView.indexPathForCell(sender as! ExpenseTableViewCell) {
                let expense = expenses[indexPath.row]
                let nav = segue.destinationViewController as! UINavigationController
                let controller = nav.topViewController as! DetailExpenseViewController
                controller.expense = expense
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ExpenseTableViewCell
        let expense = expenses[indexPath.row]
        cell.expenseName.text = expense.expenseName
        cell.expenseCost.text = "Cost: " + expense.cost
        cell.numberOfExpenseMembers.text = String(expense.payments.count)
        return cell
    }
    
    
    // MARK: - Table view data source
}
