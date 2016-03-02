//
//  NewMapViewController.swift
//  SpotAppParse
//
//  Created by xbin on 10/28/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse


class NewMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var rules = Dictionary<String,[String]>()
    
    let user = PFUser.currentUser()

    @IBOutlet weak var openParkingSpot: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    
    var canClaim = false
    
    var claimId = ""
    
    var canReport = false
    
    @IBOutlet var secondaryMenu: UIView!
    
    var destination = MKMapItem?()
    
    var manager: CLLocationManager!

    var latLocal:Double = 0.0
    var lonLocal:Double = 0.0
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBAction func refreshMap(sender: AnyObject) {
        let annotationsToRemove = map.annotations
        self.map.removeAnnotations(annotationsToRemove)
    }
    
    @IBAction func getSpots(sender: AnyObject) {
        // Create a query for spots
        let query = PFQuery(className:"spot")
        
        // Set geoPoint of users location called point
        let point = PFGeoPoint(latitude: latLocal, longitude: lonLocal)

        // Interested in locations within 10 miles of user.
        query.whereKey("location", nearGeoPoint:point, withinMiles: 5)
        
        query.whereKey("isTaken", equalTo: false)

        // Limit what could be a lot of points.
        query.limit = 10
        
        // Final list of objects
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                // cycles through the (up to) 10 spots and adds each of them to the map.
                for spots in objects!{
                    let point = spots["location"]
                    
                    let annotation = CustomPointAnnotationOpenSpot()
                    annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                    annotation.title = "Open Spot!"
                    annotation.subtitle = spots.objectId!
                    self.map.addAnnotation(annotation)
                }
                

            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
  
    @IBAction func saveParkLocation(sender: AnyObject) {
        self.saveLocation(latLocal, longitude: lonLocal)
    }
    
    @IBAction func indicateParking(sender: AnyObject) {
        self.indicateParkingLocation(latLocal, longitude: lonLocal)
    }
   
    @IBAction func meterButton(sender: AnyObject) {
        performSegueWithIdentifier("meter", sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    func zoomInOnce() {
        
        let coordinate = CLLocationCoordinate2DMake(latLocal, lonLocal)
        
        let latDelta:CLLocationDegrees = 0.05
        
        let lonDelta:CLLocationDegrees = 0.05
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        self.map.setRegion(region, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.map.showsUserLocation = true
        
        if activePlace == -1 {
            manager.requestAlwaysAuthorization()
            manager.startUpdatingLocation()
            
            let triggerTime = (Int64(NSEC_PER_SEC) * 3)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.zoomInOnce()
            })
            
        } else {
            
            let latitude  = NSString(string: places[activePlace]["lat"]!).doubleValue
            let longitude = NSString(string: places[activePlace]["lon"]!).doubleValue
            
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            
            let latDelta:CLLocationDegrees = 0.01
            
            let lonDelta:CLLocationDegrees = 0.01
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            
            let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            
            self.map.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            
            annotation.title = places[activePlace]["name"]
            
        }
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        
        uilpgr.minimumPressDuration = 1.0
        
        map.addGestureRecognizer(uilpgr)
        
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(self.map)
            
            let newCoordinate = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            let pinLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(pinLocation, completionHandler: { (placemarks, error) -> Void in
                
                var title = ""
                var house:String = ""
                var street:String = ""
                var borough:String = ""
                
                if (error == nil) {
                    if let p = placemarks?[0] {
                        
                        var houseNumber:String = ""
                        var streetNumber:String = ""
                        var boroughName:String = ""
                        if p.subThoroughfare != nil {
                            houseNumber = p.subThoroughfare!
                            house = houseNumber
                        }
                        if p.thoroughfare != nil {
                            streetNumber = p.thoroughfare!
                            street = streetNumber
                        }
                        if p.subAdministrativeArea != nil {
                            boroughName = p.subLocality!
                            borough = boroughName
                        }
                        
                        title = "\(houseNumber) \(streetNumber)"
                        
                    }
                }
                
                
                
                street = self.parseStreet(street)
                
                house = self.parseHouse(house)
                
                
                if title == "" {
                    title = "Added \(NSDate())"
                }

                // Putting a pin into map
                
                let annotation = CustomPointAnnotationSpot()
                
                annotation.coordinate = newCoordinate
                
                annotation.title = title
                
                self.getRules(house, streetName: street, borough: borough, title: title)
                
                self.map.addAnnotation(annotation)
                
            })
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let latitude  = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        latLocal = latitude
        lonLocal = longitude
        
        
    }
    
    func indicateParkingLocation(latitude:Double, longitude:Double){
        
        let openParkingLocation = PFObject(className: "spot")
        
        openParkingLocation["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
        openParkingLocation["userId"] = user!.objectId
        openParkingLocation["isTaken"] = false
        
        openParkingLocation.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                let alertController = UIAlertController(title: "Success", message:
                    "Spot successfully reported!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Whoops", message:
                    "Looks like something went wrong...", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })

        
    }
    
    func saveLocation(latitude:Double, longitude:Double) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let location = CLLocation(latitude: latitude, longitude: longitude)
            
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            var title = ""
            var house:String = ""
            var street:String = ""
            var borough:String = ""
            
            if (error == nil) {
                if let p = placemarks?[0] {
                    var houseNumber:String = ""
                    var streetNumber:String = ""
                    var boroughName:String = ""
                    if p.subThoroughfare != nil {
                        houseNumber = p.subThoroughfare!
                        house = houseNumber
                    }
                    if p.thoroughfare != nil {
                        streetNumber = p.thoroughfare!
                        street = streetNumber
                    }
                    if p.subAdministrativeArea != nil {
                        boroughName = p.subLocality!
                        borough = boroughName
                    }
                    
                    title = "\(houseNumber) \(streetNumber)"
                    
                }
            }

            if title == "" {
                title = "Added \(NSDate())"
            }
            
            
            
            // save location information into a dictionary
            places.append(["name":title,"lat":"\(latitude)","lon":"\(longitude)"])
            
            
            for vehicle in (self.user!["vehicles"] as? NSArray)!
            {
                if vehicle[3] != nil
                {
                    if vehicle[3] as! Bool == true
                    {
                        let make = vehicle[0]!
                        let model = vehicle[1]!
                        let location = PFGeoPoint(latitude: latitude, longitude: longitude)
                        let isDefault = vehicle[3]
                        
                        let newVehicle = [make, model, location, isDefault]
                        
                        self.user!["vehicles"].replaceObjectAtIndex(self.user!["vehicles"].indexOfObject(vehicle), withObject: newVehicle)
                    }
                }
            }

            self.user!.saveEventually()
            
            street = self.parseStreet(street)
            
            house = self.parseHouse(house)
            
            self.getRules(house, streetName: street, borough: borough, title: title)

            let annotation = CustomPointAnnotationMySpot()
            
            annotation.coordinate = coordinate
            
            annotation.title = title
            
            self.map.addAnnotation(annotation)
            
            let latDelta:CLLocationDegrees = 0.0008
            let lonDelta:CLLocationDegrees = 0.0008
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            
            self.map.setRegion(region, animated: true)
            
        })
    }


    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view"
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if annotation.isKindOfClass(MKUserLocation){
            return nil;
        }
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            if annotation.isMemberOfClass(CustomPointAnnotationOpenSpot){
                pinView!.pinTintColor = .greenColor()
            }else if annotation.isMemberOfClass(CustomPointAnnotationMySpot){
                pinView!.pinTintColor = .purpleColor()
            }else {
                pinView!.pinTintColor = .redColor()
            }
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            if annotation.isMemberOfClass(CustomPointAnnotationOpenSpot){
                pinView!.pinTintColor = .greenColor()
            }else if annotation.isMemberOfClass(CustomPointAnnotationMySpot){
                pinView!.pinTintColor = .purpleColor()
            }else {
                pinView!.pinTintColor = .redColor()
            }
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            canReport = false
            canClaim = false
            let userLocation = CLLocation(latitude: latLocal, longitude: lonLocal)
            let pinLocation = CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
            
            if view.annotation!.title! == "Open Spot!" && userLocation.distanceFromLocation(pinLocation) < 200.0 {
                canClaim = true
            }else if userLocation.distanceFromLocation(pinLocation) < 200.0 {
                canReport = true
            }
            
            let actionSheet = UIAlertController(title: "Spot App", message: nil, preferredStyle: .ActionSheet)
            
            let reportAction = UIAlertAction(title: "Report Spot", style: .Default, handler: { action in
                self.reportSpot(pinLocation)
            })
            
            let claimAction = UIAlertAction(title: "Claim Spot", style: .Destructive, handler: { action in
                self.claimSpot(view.annotation!.subtitle!!)
                mapView.removeAnnotation(view.annotation!)
            })
            
            let rulesAction = UIAlertAction(title: "Get Rules", style: .Default, handler: { action in
                self.showRules(view.annotation!.title!!)
                
            })

            let canelAction = UIAlertAction(title: " l", style: .Cancel, handler: nil)
            
            if canReport {
                reportAction.enabled = true
            }else{
                reportAction.enabled = false
            }
            if canClaim {
                claimAction.enabled = true
            }else{
                claimAction.enabled = false
            }

            actionSheet.addAction(rulesAction)
            actionSheet.addAction(reportAction)
            actionSheet.addAction(claimAction)
            actionSheet.addAction(canelAction)

            self.presentViewController(actionSheet, animated: true, completion: nil)
            
        }
    }
    
    func reportSpot(pinLocation: CLLocation) {
        self.indicateParkingLocation(pinLocation.coordinate.latitude, longitude: pinLocation.coordinate.longitude)
    }
    
    func claimSpot(id: String) {
        let query = PFQuery(className:"spot")
        query.getObjectInBackgroundWithId(id) {
            (spot: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let spot = spot {
                spot["isTaken"] = true
                spot.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        let alertController = UIAlertController(title: "Success", message:
                            "Spot successfully claimed!", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Whoops", message:
                            "Looks like something went wrong...", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                })
            }
        }
        
    }
    
    
    func showRules(title: String){
        
        if self.rules[title] == nil {
            
            let alertController = UIAlertController(title: "Whoops", message:
                "Looks like things are taking awhile, please try again!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else if self.rules[title]! == [""] {
            let alertController = UIAlertController(title: "Uh-Oh", message:
                "Looks like there are no rules found... Blame NYC API...", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "\(title)", message:
                "\(self.rules[title]!)", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: - REST calls
    // This makes the GET call to httpbin.org. It simply gets the IP address and displays it on the screen.
    func getRules(houseNumber : String, streetName : String, borough : String, title : String) {
        
        // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
        let postEndpoint: String = "http://alternateside.nyc/api/v3/location/\(borough)/\(streetName)/\(houseNumber)"
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: postEndpoint)!
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            print(realResponse.statusCode)
            
            
            // Read the JSON
            do {
                if let results = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                    var rules = [""]
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    for var index = 0; index < jsonDictionary["results"]?.count; ++index {
                        let rule = jsonDictionary["results"]![index] as! String
                        rules.append(rule)
                    }
                    self.rules.updateValue(rules, forKey: title)

                }
            } catch {
                print("bad things happened")
            }
        }).resume()
    }
    
    func parseStreet(var street: String) -> String {
        if street.rangeOfString("Ave") != nil{
            street.replaceRange(street.rangeOfString("Ave")!, with: "AVENUE")
        }
            
        else if street.rangeOfString("Rd") != nil{
            street.replaceRange(street.rangeOfString("Rd")!, with: "ROAD")
        }
            
        else if street.rangeOfString("Dr") != nil{
            street.replaceRange(street.rangeOfString("Dr")!, with: "DRIVE")
        }
            
        else if street.rangeOfString("St") != nil{
            street.replaceRange(street.rangeOfString("St")!, with: "STREET")
        }
        
        if let range = street.rangeOfString("\\d*(st|nd|rd|th)", options: .RegularExpressionSearch) {
            let newRange = Range<String.Index>(start: range.endIndex.advancedBy(-2), end: range.endIndex )
            street = street.stringByReplacingCharactersInRange(newRange, withString: "")
        }
        
        while let range = street.rangeOfString("\\s", options: .RegularExpressionSearch) {
            street = street.stringByReplacingCharactersInRange(range, withString: "%20")
        }
        
        return street
    }
    
    func parseHouse(var house: String) -> String {
        
        if let range = house.rangeOfString("(\\d*–)", options: .RegularExpressionSearch) {
            house = house.stringByReplacingCharactersInRange(range, withString: "")
        }

        return house
    }

    class CustomPointAnnotationOpenSpot: MKPointAnnotation {
        var rules: [String] = []
    }

    class CustomPointAnnotationMySpot: MKPointAnnotation {
        var rules: [String] = []
    }
    
    class CustomPointAnnotationSpot: MKPointAnnotation {
        var rules: [String] = []
    }
}



