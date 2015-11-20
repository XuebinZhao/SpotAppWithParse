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
    var userId = [""]
    var make  = [""]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Cars")
        
        request.returnsObjectsAsFaults = false
        
        do {
            self.model.removeAll(keepCapacity: true)
            self.userId.removeAll(keepCapacity: true)
            self.make.removeAll(keepCapacity: true)
            
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    self.model.append(result.valueForKey("model") as! String)
                    self.userId.append(result.valueForKey("userId") as! String)
                    self.make.append(result.valueForKey("make") as! String)
                }
            }
        } catch {
            
            print("Fetch Failed")
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "modifyCar" {
            let vc: ModifyCarViewController = segue.destinationViewController as! ModifyCarViewController
            
            let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            
            vc.index = (selectedIndex?.row)!
        } else {
            let vc: ModifyCarViewController = segue.destinationViewController as! ModifyCarViewController
            
            vc.addCar = true
        }
        
    }

    
    
    
}
