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
    let reuseIdentifierForAddExpenseSegue = "addExpenseSegue"
    let reuseIdentifierForExpenseDetailSegue = "showExpenseDetail"
    let reuseIdentifierForGroupStatisticsSegue = "showStatistics"
    var expenses: Array = [Expense]()
    var groupMembers: [Member]?
    var myID: String?
    var groupID: String?
    var group: Group?
    @IBOutlet weak var statisticButton: UIBarButtonItem!
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
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        if expenses.isEmpty {
            self.showError("We did not find any expenses for you")
            statisticButton.enabled = false
        }

        let name = "Pattern~\("DetailGroupViewController")"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == reuseIdentifierForExpenseDetailSegue {
            if let indexPath = self.tableView.indexPathForCell(sender as! ExpenseTableViewCell) {
                let expense = expenses[indexPath.row]
                let nav = segue.destinationViewController as! UINavigationController
                let controller = nav.topViewController as! DetailExpenseViewController
                controller.expense = expense
            }
        }
        if segue.identifier == reuseIdentifierForAddExpenseSegue {
            let groupID: String = self.groupID!
            let payerID: String = self.myID!
            let controller = segue.destinationViewController as! AddExpenseViewController
            controller.groupID = groupID
            controller.payerID = payerID
            controller.groupMembers = groupMembers
        }
        if segue.identifier == reuseIdentifierForGroupStatisticsSegue {
            let group: Group = self.group!
            let controller = segue.destinationViewController as! StatisticGroupViewController
            controller.group = group
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
        let costAdapted = String(format: "%.2f", expense.cost)
        cell.expenseCost.text = "Cost: " + String(costAdapted)
        cell.numberOfExpenseMembers.text = " Members: " + String(expense.payments.count)
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
    // MARK: - Table view data source
}
