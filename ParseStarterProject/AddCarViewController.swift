//
//  AddCarViewController.swift
//  SpotAppParse
//
//  Created by xbin on 11/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import CoreData
import Parse

class AddCarViewController: UIViewController {

    @IBOutlet weak var model: UITextField!
    @IBOutlet weak var make: UITextField!
    
    @IBAction func addCar(sender: AnyObject) {
        setNewCar()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNewCar(){
        let user = PFUser.currentUser()
        let userID = user?.objectId
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let cars = NSEntityDescription.insertNewObjectForEntityForName("Cars", inManagedObjectContext: context)
        
        
        let carModel = model.text
        let carMake = make.text
        
        cars.setValue(carModel, forKey: "model")
        cars.setValue(carMake, forKey: "make")
        cars.setValue(userID, forKey: "userId")
        
        
        
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
