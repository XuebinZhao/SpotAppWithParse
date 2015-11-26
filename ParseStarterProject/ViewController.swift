/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse
import CoreData

//@available(iOS 8.0, *)
class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var userName: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var signUpText: UIButton!
    
    @IBOutlet var registerLabel: UILabel!
    
    @IBOutlet var logInText: UIButton!
    
    var signUpActive = true
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
        
        if userName.text == "" || password.text == "" {
            // display an alert if any field is empty
            displayAlert("Error in form", message: "Please enter a username and password")
            
        } else {
            // set up a Spinner that for the registration is processing
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later"
            
            if signUpActive == true {
                let user = PFUser()
                user.username = userName.text
                user.password = password.text
            
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if success {
                        // Signup successful
                        // update local user database as well
                        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let context: NSManagedObjectContext = appDel.managedObjectContext
                        
                        let newUser = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: context)
                        
                        newUser.setValue(user.username, forKey: "username")
                        newUser.setValue(user.objectId, forKey: "userId")
                        
                        do {
                            try context.save()
                        } catch {
                            print("There was a problem")
                        }
                        
                        let request = NSFetchRequest(entityName: "Users")
                        request.returnsObjectsAsFaults = false
                        
                        do {
                            let results = try context.executeFetchRequest(request)
                            print(results)
                        } catch {
                            print("Fetch Failed")
                        } // end updating local user table
                        
                        
                        // save user's object Id into appdelegate variable
                        let object = UIApplication.sharedApplication().delegate
                        let applicationDelegate = object as! AppDelegate
                        applicationDelegate.storeUserId = user.objectId!
                        
                        // Set a default car onto Parse car database
                        let defaultCar = PFObject(className: "car")
                        defaultCar["UserobjectId"] = user.objectId!
                        defaultCar["model"]        = "default"
                        defaultCar["make"]         = "car"
                        
                        defaultCar.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                                print("default car save")
                            } else {
                                print("default failt")
                            }
                        }) // end setting a default for new user
                        
                        
                        
                        
                        let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
                        self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
                    } else {
                        if let errorString = error!.userInfo["error"] as? String {
                            errorMessage = errorString
                        }
                        self.displayAlert("Failed Signed", message: errorMessage)
                }
            })
            } else {
                PFUser.logInWithUsernameInBackground(userName.text!, password: password.text!, block: { (user, error) -> Void in
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    if user != nil {
                        var userExist = false
                        
                        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        
                        let context: NSManagedObjectContext = appDel.managedObjectContext
                        
                        let request = NSFetchRequest(entityName: "Users")
                        
                        request.returnsObjectsAsFaults = false
                        
                        do {
                            
                            let results = try context.executeFetchRequest(request)
                            
                            if results.count > 0 {
                                
                                for result in results as! [NSManagedObject] {
                                    
                                    if result.valueForKey("userId")!.isEqual(user?.objectId) {
                                        // if the user exist in the local database, we don't need to update local database
                                        userExist = true
                                    }
                     
                                }
                                
                            }
                            
                        } catch {
                            
                            print("Fetch Failed")
                        }
                        
                        // this is updating local database, when user is not exist in local database
                        if !(userExist) {
                            let newUser = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: context)
                            let newCar = NSEntityDescription.insertNewObjectForEntityForName("Cars", inManagedObjectContext: context)
                            
                            newUser.setValue(user!.username, forKey: "username")
                            newUser.setValue(user!.objectId, forKey: "userId")
                            
                            newCar.setValue(user!.objectId, forKey: "userId")
                            newCar.setValue("Default", forKey: "model")
                            newCar.setValue("Car", forKey: "make")
                            
                            
                            do {
                                try context.save()
                            } catch {
                                print("There was a problem")
                            }
                            
                            let requestAfterInsert = NSFetchRequest(entityName: "Users")
                            requestAfterInsert.returnsObjectsAsFaults = false
                            
                            do {
                                let results = try context.executeFetchRequest(requestAfterInsert)
                                print(results)
                            } catch {
                                print("Fetch Failed")
                            }
                            
                            // try to see what is in Cars entity
                            let requestForCars = NSFetchRequest(entityName: "Cars")
                            requestForCars.returnsObjectsAsFaults = false
                            
                            do {
                                let results = try context.executeFetchRequest(requestForCars)
                                print(results)
                            } catch {
                                print("Fetch Failed")
                            }
                        }
                        
                        
                        let object = UIApplication.sharedApplication().delegate
                        let applicationDelegate = object as! AppDelegate
                        applicationDelegate.storeUserId = user!.objectId!

                        
                        let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
                        self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
                        
                    } else {
                        if let errorString = error!.userInfo["error"] as? String {
                            errorMessage = errorString
                        }
                        self.displayAlert("Failed Login", message: errorMessage)
                    }
                })
            }
        }
        
    }
    
    @IBAction func logInButton(sender: AnyObject) {
        
        if signUpActive == true {
            signUpText.setTitle("Login", forState: UIControlState.Normal)
            registerLabel.text = "Not registered?"
            logInText.setTitle("SignUp", forState: UIControlState.Normal)
            signUpActive = false
        } else {
            signUpText.setTitle("Sign Up", forState: UIControlState.Normal)
            registerLabel.text = "Already registered?"
            logInText.setTitle("Login", forState: UIControlState.Normal)
            signUpActive = true
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        userName.delegate = self
        password.delegate = self
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if let user = PFUser.currentUser(){
            if user.objectId == nil {
                print("Please register")
            }else {
                let object = UIApplication.sharedApplication().delegate
                let applicationDelegate = object as! AppDelegate
                applicationDelegate.storeUserId = user.objectId!
                
                
                let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
                self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
                //self.performSegueWithIdentifier("login", sender: self)
            }
        }
    }

}
