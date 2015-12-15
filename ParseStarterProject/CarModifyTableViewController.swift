//
//  CarModifyTableViewController.swift
//  SpotAppParse
//
//  Created by xbin on 12/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class CarModifyTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    let user = PFUser.currentUser()
    @IBOutlet weak var imagePickerView : UIImageView!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var makeTextField: UITextField!
    @IBOutlet weak var setDefault: UISwitch!
    @IBOutlet weak var addOrUpdateButton: UIButton!
    
    var index:Int = 0
    
    var addCar = false
    
    override func viewWillAppear(animated: Bool) {
        if addCar {
            addOrUpdateButton.setTitle("Add", forState: UIControlState.Normal)
        } else {
            addOrUpdateButton.setTitle("Update", forState: UIControlState.Normal)
            
            modelTextField.text! = user!["vehicles"].objectAtIndex(index)[1] as! String
            makeTextField.text! = user!["vehicles"].objectAtIndex(index)[0] as! String
            
            let checkDefault = user!["vehicles"].objectAtIndex(index)[3] as! Bool
            if checkDefault {
                setDefault.setOn(true, animated: true)
            } else {
                setDefault.setOn(false, animated: true)
            }
        }
    }
    
    @IBAction func saveCar(sender: AnyObject) {
        
        
        if addCar {

            let make = "\(makeTextField.text!)"
            let model = "\(modelTextField.text!)"
            let location = PFGeoPoint()
            var isDefault = false
            if setDefault.on {
                isDefault = true
            } else {
                isDefault = false
            }
            
            let vehicle = [make, model, location, isDefault]
            
            user!["vehicles"].insertObject(vehicle, atIndex: index)
            
            if setDefault.on {
            for var i = 1; i<user!["vehicles"].count; i++ {
                let make = user!["vehicles"][i][0]
                let model = user!["vehicles"][i][1]
                let location = user!["vehicles"][i][2]
                var isDefault = user!["vehicles"][i][3]
                isDefault = false
                let vehicle = [make, model, location, isDefault]
                user!["vehicles"].replaceObjectAtIndex(i, withObject: vehicle)
                user!.saveEventually()
            }
            }
            user!.saveEventually()
            
            let query = PFQuery(className:"car")
            let uId = user!.objectId! as String
            query.whereKey("userId", equalTo:"\(uId)")
            
            query.findObjectsInBackgroundWithBlock{
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    for object in objects! {
                        let ind = object["carIndex"] as! Int
                        print(ind)
                        object["carIndex"] = ind + 1
                        object.saveInBackground()
                    }
                }
            }
            
            let imageData: NSData = UIImageJPEGRepresentation(imagePickerView.image!, 1.0)!
            let imageForCar: PFFile = PFFile(name: "carImage.png", data: imageData)!
            
            let carImage = PFObject(className: "car")
            carImage["userId"] = user!.objectId
            carImage["carImage"] = imageForCar
            carImage["carIndex"] = index
            
            carImage.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    print(success)
                } else {
                    print (error)
                }
            })
            
            
            
            
        } else {

            let make = "\(makeTextField.text!)"
            let model = "\(modelTextField.text!)"
            let location = PFGeoPoint()
            var isDefault = user!["vehicles"][index][3]
            if setDefault.on {
                print("it is on")
                isDefault = true
            } else {
                print("it is off")
                isDefault = false
            }
            
            let vehicle = [make, model, location, isDefault]
            
            user!["vehicles"].replaceObjectAtIndex(index, withObject: vehicle)
            
            user!.saveEventually()
            
            if setDefault.on {
                for var i = 0; i<user!["vehicles"].count; i++ {
                    if i == index {
                        
                    } else {
                    let make = user!["vehicles"][i][0]
                    let model = user!["vehicles"][i][1]
                    let location = user!["vehicles"][i][2]
                    var isDefault = user!["vehicles"][i][3]
                    isDefault = false
                    let vehicle = [make, model, location, isDefault]
                    user!["vehicles"].replaceObjectAtIndex(i, withObject: vehicle)
                    user!.saveEventually()
                    }
                }
            }
            
            let query = PFQuery(className:"car")
            let uId = user!.objectId! as String
            query.whereKey("userId", equalTo:"\(uId)")
            
            query.findObjectsInBackgroundWithBlock{
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    for object in objects! {
                        if object["carIndex"].isEqual(self.index) {
                            let imageData: NSData = UIImageJPEGRepresentation(self.imagePickerView.image!, 1.0)!
                            let imageForCar: PFFile = PFFile(name: "carImage.png", data: imageData)!
                            object["carImage"] = imageForCar
                            object.saveInBackground()
                        }
                    }
                }
            }
        }
        let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
        self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor(red: 243.0/255, green: 243.0/255, blue: 243.0/255, alpha: 1)
        modelTextField.delegate = self
        makeTextField.delegate = self
        
        if addCar {
            let getImage = UIImage(named: "car_default.png")
            imagePickerView.image = getImage
        }else {
            let query = PFQuery(className:"car")
            let uId = user!.objectId! as String
            query.whereKey("userId", equalTo:"\(uId)")
            
            query.findObjectsInBackgroundWithBlock{
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    for object in objects! {
                        if object["carIndex"].isEqual(self.index) {
                            if let imageFile: PFFile = object["carImage"] as? PFFile{
                                imageFile.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                                    if error == nil {
                                        let image = UIImage(data: imageData!)
                                        self.imagePickerView.image = image
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.textColor = UIColor(red: 151.0/255, green: 193.0/255, blue: 100.0/255, alpha: 1)
        let font = UIFont(name: "Helvetica Neue", size: 14.0)
        headerView.textLabel!.font = font!
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func ChooseImage(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            imagePickerView.contentMode = .ScaleAspectFit
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
