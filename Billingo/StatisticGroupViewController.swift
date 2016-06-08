//
//  StatisticGroupViewController.swift
//  Billingo
//
//  Created by Matej Minarik on 07/06/16.
//  Copyright © 2016 MU. All rights reserved.
//

import Foundation


class StatisticGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //@IBOutlet weak var groupName: UILabel!  //moze byt nemusi byt, mohlo by byt pekne niekde hore vidiet v akej som skupine
    @IBOutlet weak var groupName: UINavigationItem!
    
    var expense: Expense?
    var name: String?
    var members: Member?
    var group: Group?
    let reuseIdentifier = "statisticCell"
    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (group?.members.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StatisticGroupTableViewCell
        // Configure the cell
        cell.memberName.text = group?.members[indexPath.item].memberName
        
        var numPayments = 0
        var balanceOfPayments = 0.0
        for expense in (group?.expenses)! {
            if expense.expenseCreatorID == group?.members[indexPath.item].memberID {
                numPayments += 1
                for payment in expense.payments {
                    if payment.userID != group?.members[indexPath.item].memberID{
                        balanceOfPayments += payment.cost
                    }
                }
            }else{
                for payment in expense.payments {
                    if payment.userID == group?.members[indexPath.item].memberID{
                        balanceOfPayments -= payment.cost
                    }
                }
            }
        }
        cell.memberCredit.text = "Stav: \(balanceOfPayments)"
        if balanceOfPayments < 0 {
            cell.memberCredit.textColor = UIColor.redColor()
        }else{
            cell.memberCredit.textColor = UIColor.blackColor()
        }
        cell.memberCreatedPayments.text = "zaplatil \(numPayments) výdajov"
        return cell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        groupName.title = group?.name
    }
}