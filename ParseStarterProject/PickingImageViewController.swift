//
//  PickingImageViewController.swift
//  SpotAppParse
//
//  Created by xbin on 11/11/15.
//  Copyright © 2015 Parse. All rights reserved.
//
import UIKit
import Parse

class PickingImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let user = PFUser.currentUser()

    @IBOutlet weak var imagePickerView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.hidden = true
    }

    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker        = UIImagePickerController()
        imagePicker.delegate   = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func savePhoto(sender: AnyObject) {
        let profileController = self.storyboard!.instantiateViewControllerWithIdentifier("profileController") as! ProfileEditViewController
        profileController.userImage = imagePickerView
        
        let imageData: NSData = UIImageJPEGRepresentation(imagePickerView.image!, 1.0)!
        let userImage: PFFile = PFFile(name: "profileImage.png", data: imageData)!
        
        user?.setObject(userImage, forKey: "userImage")
        user?.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {

            } else {
                print("Something wrong")
            }
        })
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
