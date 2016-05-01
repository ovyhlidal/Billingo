//
//  DerailGroupTableViewController.swift
//  Billingo
//
//  Created by Zuzana Plesingerova on 28.04.16.
//  Copyright © 2016 MU. All rights reserved.
//

import UIKit

let reuseIdentifier = "ExpenseCell"

class DetailGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var expenses: Array = [Expense]()
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backToGroupsView(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        self.tableView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        cell.numberOfExpenseMembers.text = String(expense.members.count)
        return cell
    }
    
    
    // MARK: - Table view data source
}
