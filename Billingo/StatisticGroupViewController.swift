//
//  StatisticGroupViewController.swift
//  Billingo
//
//  Created by Matej Minarik on 07/06/16.
//  Copyright © 2016 MU. All rights reserved.
//

import Foundation


class StatisticGroupViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var groupName: UILabel!  //moze byt nemusi byt, mohlo by byt pekne niekde hore vidiet v akej som skupine
    
    var expense:Expense?
    var name:String?
    var members:Member?
    var group:Group?
    let reuseIdentifier = "memberCell"
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> StatisticGroupViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! StatisticGroupViewCell
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
        cell.memberCredit.text = "\(balanceOfPayments)"
        if balanceOfPayments < 0 {
            cell.memberCredit.textColor = UIColor.redColor()
        }else{
            cell.memberCredit.textColor = UIColor.blackColor()
        }
        cell.memberCreatedPayments.text = "zaplatil \(numPayments) výdajov"
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView:UICollectionView) -> Int {
        return 1
    }
    
    //number of groups for current user
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (group?.members.count)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        groupName.text = group?.name
    }
}