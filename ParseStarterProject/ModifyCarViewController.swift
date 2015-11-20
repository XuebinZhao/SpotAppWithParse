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
    
    var index:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        modelTextField.delegate = self
        makeTextField.delegate = self
     }
    
    override func viewWillAppear(animated: Bool) {
        print(index)
        
        let user = PFUser.currentUser()
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Cars")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                
                print(results[0])
                
                for result in results as! [NSManagedObject] {
                    if result.valueForKey("userId")!.isEqual(user?.objectId) {
                        let model = String(result.valueForKey("model")!)
                        modelTextField.text = model
                        makeTextField.text = String(result.valueForKey("make")!)
                    }
                }
            }
        } catch {
            print("Fetch Failed")
        }
        
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func updateCar(sender: AnyObject) {
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Cars")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                
                print(results[0])
                
                let managedObject = results[0]
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
        
        let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
        self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
        
//        let requestForCars = NSFetchRequest(entityName: "Cars")
//        requestForCars.returnsObjectsAsFaults = false
//        // to see did I update
//        do {
//            let results = try context.executeFetchRequest(requestForCars)
//            print(results)
//        } catch {
//            print("Fetch Failed")
//        }
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
