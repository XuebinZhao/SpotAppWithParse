//
//  UserProfileViewController.swift
//  SpotAppParse
//
//  Created by xbin on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UserProfileViewController: UIViewController {

    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var UserName: UILabel!
    
    @IBOutlet weak var UserImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        let user = PFUser.currentUser()
        if let imageFile: PFFile = user!["userImage"] as? PFFile{
            
            imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                if error == nil {
                    let image = UIImage(data: imageData!)
                    self.UserImage.image = image
                }
            }
        }
        if let firstName = user!["firstName"] {
            fullName.text = "\(firstName) \(user!["lastName"])"
        } else {
            fullName.text = ""
        }
        if let userName = user!["username"] {
            UserName.text = "\(userName)"
        } else {
            fullName.text = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // logout from current user
    @IBAction func logoutButton(sender: AnyObject) {
        PFUser.logOut()
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // instantiate your desired ViewController
            let rootController = storyboard.instantiateViewControllerWithIdentifier("welcome")
            
            self.presentViewController(rootController, animated: true, completion: nil)
        }
    }

}
