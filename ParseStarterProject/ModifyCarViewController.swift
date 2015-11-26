//
//  ModifyCarViewController.swift
//  SpotAppParse
//
//  Created by xbin on 11/19/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreData

class ModifyCarViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var modelTextField: UITextField!
    
    @IBOutlet weak var makeTextField: UITextField!
    
    @IBOutlet weak var addOrUpdateButton: UIButton!
    var index:Int = 0
    
    var addCar = false
    
    var cars = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        modelTextField.delegate = self
        makeTextField.delegate = self
     }
    
    override func viewWillAppear(animated: Bool) {
        if addCar {
            addOrUpdateButton.setTitle("Add", forState: UIControlState.Normal)
        } else {
            addOrUpdateButton.setTitle("Update", forState: UIControlState.Normal)
        
        
        let user = PFUser.currentUser()
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Cars")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if result.valueForKey("userId")!.isEqual(user?.objectId) {
                        cars.append(result)
                    }
                }
                let car = cars[index]
                modelTextField.text =
                    car.valueForKey("model") as? String
                makeTextField.text =
                    car.valueForKey("make") as? String
            }
        } catch {
            print("Fetch Failed")
        }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func updateCar(sender: AnyObject) {
        if addCar {
            //addOrUpdateButton.setTitle("Add", forState: UIControlState.Normal)
            let user = PFUser.currentUser()
            let userID = user?.objectId
            
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let context: NSManagedObjectContext = appDel.managedObjectContext
            
            let cars = NSEntityDescription.insertNewObjectForEntityForName("Cars", inManagedObjectContext: context)
            
            cars.setValue(modelTextField.text, forKey: "model")
            cars.setValue(makeTextField.text, forKey: "make")
            cars.setValue(userID, forKey: "userId")
            //cars.setValue(carID,  forKey: "objectId")
            do {
                try context.save()
            } catch {
                print("There was a problem")
            }
        } else {
            let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let context: NSManagedObjectContext = appDel.managedObjectContext
            
            let request = NSFetchRequest(entityName: "Cars")
            request.returnsObjectsAsFaults = false
            do {
                let results = try context.executeFetchRequest(request)
                
                if results.count > 0 {
                    
                    print(results[index])
                    
                    let managedObject = results[index]
                    managedObject.setValue(modelTextField.text, forKey:"model")
                    managedObject.setValue(makeTextField.text, forKey:"make")
                    do {
                        try context.save()
                    } catch {
                        print("There was a problem")
                    }
                }
            } catch {
                print("Fetch Failed")
            }
        }
        
        let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
        self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
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
