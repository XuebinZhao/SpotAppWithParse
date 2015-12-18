//
//  CarListTableViewController.swift
//  SpotAppParse
//
//  Created by xbin on 11/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreData

class CarListTableViewController: UITableViewController {
    
    var model  = [""]
    var make  = [""]
    
    let user = PFUser.currentUser()

    override func viewDidLoad() {
        super.viewDidLoad()

            self.model.removeAll(keepCapacity: true)
            self.make.removeAll(keepCapacity: true)

            for vehicle in (user!["vehicles"] as? NSArray)!
            {
                if(vehicle[0] != nil){
                    self.make.append((vehicle[0] as? String)!)
                }
                if(vehicle[1] != nil){
                    self.model.append((vehicle[1] as? String)!)
                }
            }
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = model[indexPath.row]
        cell.detailTextLabel?.text = make[indexPath.row]
        

        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        
        if segue.identifier == "modifyCar" {
            let vc: CarModifyTableViewController = segue.destinationViewController as! CarModifyTableViewController
            
            let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            
            vc.index = (selectedIndex?.row)!
        } else {
            let vc: CarModifyTableViewController = segue.destinationViewController as! CarModifyTableViewController
            
            vc.addCar = true
        }
        
    }

    
    
    
}
