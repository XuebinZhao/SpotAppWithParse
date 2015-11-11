//
//  ProfileEditViewController.swift
//  SpotAppParse
//
//  Created by xbin on 11/10/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ProfileEditViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        
        let user = PFUser.currentUser()
        let imageFile: PFFile = user!["userImage"] as! PFFile
        
        imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
            if error == nil {
                let image = UIImage(data: imageData!)
                self.userImage.image = image
            }
        }
        
        
//        PFFile *imageFile = [object objectForKey:@"profileImage"];
//        cell.thumbnailProfilePic.file = imageFile;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func saveProfile(sender: AnyObject) {
        print(firstNameText.text)
        print(lastNameText.text)
        let user = PFUser.currentUser()
        
        user?.setValue(firstNameText.text, forKey: "firstName")
        user?.setValue(lastNameText.text,  forKey: "lastName")
        
        
        user?.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
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
