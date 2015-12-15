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
    
    let user = PFUser.currentUser()

    @IBOutlet weak var modelTextField: UITextField!
    
    @IBOutlet weak var makeTextField: UITextField!
    
    @IBOutlet weak var addOrUpdateButton: UIButton!
    
    var index:Int = 0
    
    var addCar = false
    
    //var cars = [NSManagedObject]()
    
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

            modelTextField.text! = user!["vehicles"].objectAtIndex(index)[1] as! String
            makeTextField.text! = user!["vehicles"].objectAtIndex(index)[0] as! String
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func updateCar(sender: AnyObject) {
        if addCar {
            
            let make = "\(makeTextField.text!)"
            let model = "\(modelTextField.text!)"
            let location = PFGeoPoint()
            let isDefault = false
            
            let vehicle = [make, model, location, isDefault]
            
            user!["vehicles"].insertObject(vehicle, atIndex: index)
            
            user!.saveEventually()
            

        } else {
            
            let make = "\(makeTextField.text!)"
            let model = "\(modelTextField.text!)"
            let location = PFGeoPoint()
            let isDefault = user!["vehicles"][index][3]
        
            let vehicle = [make, model, location, isDefault]
            
            for i in 0..<user!["vehicles"].count{
                 user!["vehicles"][i].replaceObjectAtIndex(3, withObject: false)
            }
            
            user!["vehicles"].replaceObjectAtIndex(index, withObject: vehicle)
            
            user!.saveEventually()

        }
        let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
        self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
