//
//  UserProfileViewController.swift
//  SpotAppParse
//
//  Created by xbin on 11/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreData

class UserProfileViewController: UIViewController {
    
    let user = PFUser.currentUser()

    @IBOutlet weak var fullName: UILabel!
    
    @IBOutlet weak var UserName: UILabel!
    
    @IBOutlet weak var carName: UILabel!
    
    @IBOutlet weak var UserImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {

        if let imageFile: PFFile = user!["userImage"] as? PFFile{
            
            imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                if error == nil {
                    let image = UIImage(data: imageData!)
                    self.UserImage.image = image
                }
            }
        }
        
        fullName.text! = "\(user!["firstName"]) \(user!["lastName"])"
        
        UserName.text! = "\(user!["username"])"
        
        for vehicle in (user!["vehicles"] as? NSArray)!
        {
            if vehicle[3] as? Bool == true
            {
                self.carName.text! = "\(vehicle[0]) \(vehicle[1])"
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // logout from current user
    @IBAction func logoutButton(sender: AnyObject) {
        user!.unpinInBackground()
        PFUser.logOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // instantiate your desired ViewController
        let rootController = storyboard.instantiateViewControllerWithIdentifier("welcome")
        
        self.presentViewController(rootController, animated: true, completion: nil)
    }

}
