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
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        expenseCreateDate.text = dateFormatter.stringFromDate((expense?.expenseCreateDate)!)
        expenseCreator.text = expense?.expenseCreatorName
        expenseCost.text = "Výdej: " + String((expense?.cost)!)
        self.tableView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        let name = "Pattern~\("DetailExpenseController")"
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: name)
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Dlužníci"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (expense?.payments.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ExpenseDetailTableViewCell
        
        let user :String = (self.expense?.payments[indexPath.row].userName)!
        cell.usrName.text = user
        let debt = ((expense?.cost)! / Double((expense?.payments.count)!))
        //print(debt)
        let debtAdapted = String(format: "%.2f", debt)
        cell.userDebt.text = "Dlh:" + debtAdapted
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
