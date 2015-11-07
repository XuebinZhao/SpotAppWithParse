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

@available(iOS 8.0, *)
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
            self.dismissViewControllerAnimated(true, completion: nil)
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
                
                if error == nil {
                    // Signup successful
                    self.performSegueWithIdentifier("login", sender: self)
                    
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
                        // Assuming type has a reference to managed object context
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        
                        let managedObjectContext = appDelegate.managedObjectContext
                        
                        let fetchRequest = NSFetchRequest(entityName: "User")
                        do {
                            let fetchedEntities = try managedObjectContext.executeFetchRequest(fetchRequest) as! [User]
                            
                            let person = fetchedEntities[0]
                            
                            person.username = user?.username
                            
                            // Do something with fetchedEntities
                            
                        } catch {
                        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedObjectContext)
                            let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
                            person.setValue(user?.username, forKey: "username")
                        }
                        
                        
                        do {
                            try managedObjectContext.save()
                        } catch {
                            fatalError("SHIT WENT DOWN... \(error)")
                        }
                        
                        //let fetchRequest1 = NSFetchRequest(entityName: "User")
                        //let fetchedEntities = try managedObjectContext.executeFetchRequest(fetchRequest1) as! [User]
                        //let person1 = fetchedEntities[0]
                        
                        logIn = true
                        self.performSegueWithIdentifier("login", sender: self)
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
        if logIn == true {
            if let user = PFUser.currentUser(){
                if user.objectId == nil {
                    print("Please register")
                }else {
                    self.performSegueWithIdentifier("login", sender: self)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
