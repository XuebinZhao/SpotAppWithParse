//
//  ProfileEditViewController.swift
//  SpotAppParse
//
//  Created by xbin on 11/10/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileEditViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = false
        firstNameText.delegate = self
        lastNameText.delegate  = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        
        let user = PFUser.currentUser()
        if let imageFile: PFFile = user!["userImage"] as? PFFile{
        
        imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
            if error == nil {
                let image = UIImage(data: imageData!)
                self.userImage.image = image
            }
            
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveProf(sender: AnyObject) {
        print(firstNameText.text)
        print(lastNameText.text)
        let user = PFUser.currentUser()
        
        user?.setValue(firstNameText.text, forKey: "firstName")
        user?.setValue(lastNameText.text,  forKey: "lastName")
        
        
        user?.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                //self.dismissViewControllerAnimated(true, completion: nil)
                let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
                self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
                
            } else {
                print("Something wrong")
            }
        })
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
