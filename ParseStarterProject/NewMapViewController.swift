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
                    
                    let annotation = MKPointAnnotation()
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
            
            //self.map.addAnnotation(annotation)
            
            // **********************************************************************
            // code for route direction
            
            let place = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
            destination = MKMapItem(placemark: place)
            
            let request = MKDirectionsRequest()
            request.source = MKMapItem.mapItemForCurrentLocation()
            request.destination = destination!
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            directions.calculateDirectionsWithCompletionHandler({ (response: MKDirectionsResponse?, error:NSError?) -> Void in
                if error != nil {
                    // if error then handle it
                } else {
                    self.showRoute(response!)
                }
            })
            // **********************************************************************
            
        }
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        
        uilpgr.minimumPressDuration = 1.0
        
        map.addGestureRecognizer(uilpgr)
        
    }
    
    func showDirections(lat: Double, lon: Double) {
        let coordinate = CLLocationCoordinate2DMake(latLocal+lat, lonLocal+lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        let place = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        destination = MKMapItem(placemark: place)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destination!
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler({ (response: MKDirectionsResponse?, error:NSError?) -> Void in
            if error != nil {
                // if error then handle it
            } else {
                self.showRoute(response!)
            }
        })
    }
    
    // **********************************************************************
    func showRoute(response:MKDirectionsResponse) {
        for route in response.routes {
            map.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            
            for step in route.steps {
                var subString: String
                if step.instructions.hasPrefix("Proceed"){}
                if step.instructions.hasPrefix("Arrive"){}
                if step.instructions.hasPrefix("The destination"){}
                if step.instructions.hasPrefix("Make a U-turn at")
                {
                    subString = step.instructions
                    subString = subString.stringByReplacingOccurrencesOfString("Make a U-turn at ", withString: "")
                    print(subString)
                }
                if step.instructions.hasPrefix("Turn right onto ")
                {
                    subString = step.instructions
                    subString = subString.stringByReplacingOccurrencesOfString("Turn right onto ", withString: "")
                    print(subString)
                }
                if step.instructions.hasPrefix("Turn left onto ")
                {
                    subString = step.instructions
                    subString = subString.stringByReplacingOccurrencesOfString("Turn left onto ", withString: "")
                    print(subString)
                }
                
            }
        }
//        let region = MKCoordinateRegionMakeWithDistance(userLocation!.coordinate, 2000, 2000)
//        map.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    // **********************************************************************
    
    
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(self.map)
            
            let newCoordinate = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            let pinLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(pinLocation, completionHandler: { (placemarks, error) -> Void in
                
                var title = ""
                
                if (error == nil) {
                    if let p = placemarks?[0] {
                        var subThoroughfare:String = ""
                        var thoroughfare:String = ""
                        
                        if p.subThoroughfare != nil {
                            subThoroughfare = p.subThoroughfare!
                        }
                        if p.thoroughfare != nil {
                            thoroughfare = p.thoroughfare!
                        }

                        title = "\(subThoroughfare) \(thoroughfare)"
                        
                    }
                }
                
                if title == "" {
                    title = "Added \(NSDate())"
                }

                // Putting a pin into map
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = newCoordinate
                
                annotation.title = title
                
                // Try to add a UIButton in the pin
                //annotation.
                
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
            
            if (error == nil) {
                if let p = placemarks?[0] {
                    var subThoroughfare:String = ""
                    var thoroughfare:String = ""
                    
                    if p.subThoroughfare != nil {
                        subThoroughfare = p.subThoroughfare!
                    }
                    if p.thoroughfare != nil {
                        thoroughfare = p.thoroughfare!
                    }
                    
                    title = "\(subThoroughfare) \(thoroughfare)"
                    
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

            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            
            annotation.title = title
            
            self.map.addAnnotation(annotation)
            
            let latDelta:CLLocationDegrees = 0.0008
            let lonDelta:CLLocationDegrees = 0.0008
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
            
            self.map.setRegion(region, animated: true)
            
            self.showDirections(0.0003, lon: 0.0003)
            self.showDirections(-0.0003, lon: 0.0003)
            self.showDirections(0.0003, lon: -0.0003)
            self.showDirections(-0.0003, lon: -0.0003)
            
            self.getRules()

            
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
                if annotation.title! == "Open Spot!"{
                    pinView!.pinColor = .Green
                }else{
                    pinView!.pinColor = .Red
                }
                pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            } else {
            if annotation.title! == "Open Spot!"{
                pinView!.pinColor = .Green
            }else{
                pinView!.pinColor = .Red
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
            
            let canelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
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
    

    //MARK: - REST calls
    // This makes the GET call to httpbin.org. It simply gets the IP address and displays it on the screen.
    func getRules() {
        var HOUSENUM : String! = "33-41"
        var STREET : String! = "61STREET"
        var BOROUGH : String = "QUEENS"
        
        // Setup the session to make REST GET call.  Notice the URL is https NOT http!!
        let postEndpoint: String = "http://alternateside.nyc/api/v3/location/queens/61%20STREET/33-41"
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
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let address = jsonDictionary["results"]
                    print(address)
                }
            } catch {
                print("bad things happened")
            }
        }).resume()
    }
    
    
    func postDataToURL() {
        
        // Setup the session to make REST POST call
        let postEndpoint: String = "http://requestb.in/r4jz64r4"
        let url = NSURL(string: postEndpoint)!
        let session = NSURLSession.sharedSession()
        let postParams : [String: AnyObject] = ["hello": "Hello POST world"]
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print(postParams)
        } catch {
            print("bad things happened")
        }
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            if let postString = NSString(data:data!, encoding: NSUTF8StringEncoding) as? String {
                // Print what we got from the call
                print("POST: " + postString)
                self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
            }
            
        }).resume()
    }
    
    //MARK: - Methods to update the UI immediately
    func updateIPLabel(text: String) {
        var ipLabel = "Your IP is " + text
    }
    
    func updatePostLabel(text: String) {
        var postResultLabel = "POST : " + text
    }
}
    
    

