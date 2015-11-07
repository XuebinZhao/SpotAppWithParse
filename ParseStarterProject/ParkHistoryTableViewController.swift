//
//  LocationTableViewController.swift
//  SpotAppParse
//
//  Created by xbin on 10/28/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit

var places = [Dictionary<String,String>()]

var activePlace = -1

class ParkHistoryTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if places.count == 1 {
            
            places.removeAtIndex(0)
            
            places.append(["name":"Grand Central","lat":"40.7528","lon":"-73.9765"])
        }
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
        return places.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        cell.textLabel?.text = places[indexPath.row]["name"]

        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        activePlace = indexPath.row
        return indexPath
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }


    

}
