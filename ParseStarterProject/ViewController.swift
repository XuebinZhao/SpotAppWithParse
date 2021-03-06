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
                        
                        let make : String! = "car"
                        let model : String! = "defualt"
                        let location = PFGeoPoint()
                        let isDefault = true
                        
                        let vehicle = [make, model, location, isDefault]
                        
                        let vehicles = [vehicle]
                        
                        user["vehicles"] = vehicles
                        user["firstName"] = "Spot"
                        user["lastName"] = "User"
                        
                        user.pinInBackground()
                        
                        user.saveEventually()
                        
                        let getImage = UIImage(named: "car_default.png")
                        let imageData: NSData = UIImageJPEGRepresentation(getImage!, 1.0)!
                        let imageForCar: PFFile = PFFile(name: "carImage.png", data: imageData)!
                        
                        let carImage = PFObject(className: "car")
                        carImage["userId"] = user.objectId
                        carImage["carImage"] = imageForCar
                        carImage["carIndex"] = 0
                        
                        carImage.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                                print(success)
                            } else {
                                print (error)
                            }
                        })
                        
                        let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
                        self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
                        
                    } else {
                        if let errorString = error!.userInfo["error"] as? String {
                            errorMessage = errorString
                        }
                        self.displayAlert("Failed Sign-up", message: errorMessage)
                    }
                })
            } else {
                // begin to process login steps
                PFUser.logInWithUsernameInBackground(userName.text!, password: password.text!, block: { (user, error) -> Void in
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    if user != nil {
                        
                        user!.pinInBackground()
                        
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
                
                let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
                self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
            }
        }
    }
    
}
