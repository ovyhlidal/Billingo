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
    
    let reuseIdentifier = "groupCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groups.append(Group())
        groups.append(Group())
        groups.append(Group())
        groups.append(Group())
        groups.append(Group())
        
        groupCollectionView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.groupName.text = "Test"
        
        return cell
    }
    
    
}

