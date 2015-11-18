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

    @IBOutlet weak var openParkingSpot: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    
    var destination = MKMapItem?()
    
    var manager: CLLocationManager!
    
    var saveCheck = false

    var latLocal:Double = 0.0
    var lonLocal:Double = 0.0
    
//    var latDelta:CLLocationDegrees = 0.01
//    var lonDelta:CLLocationDegrees = 0.01
    
    
    @IBAction func refreshMap(sender: AnyObject) {
        let annotationsToRemove = map.annotations
        self.map.removeAnnotations(annotationsToRemove)
    }
    
    @IBAction func getSpots(sender: AnyObject) {
        var query = PFQuery(className:"spot")
        // User's location
        let user = PFUser.currentUser()
        
        let point = PFGeoPoint(latitude: latLocal, longitude: lonLocal)
        // Create a query for places
        // Interested in locations near user.
        query.whereKey("location", nearGeoPoint:point)
        // Limit what could be a lot of points.
        query.limit = 10
        // Final list of objects
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) locations.")
                
                // cycles through the 10 spots and adds each of them to the map.
                for spots in objects!{
                    var point = spots["location"]
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(point.latitude, point.longitude)
                    self.map.addAnnotation(annotation)
                }
                

            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
  
    @IBAction func saveParkLocation(sender: AnyObject) {
        saveCheck = true
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
    
    // **********************************************************************
    func showRoute(response:MKDirectionsResponse) {
        for route in response.routes {
            map.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            
            for step in route.steps {
                print(step.instructions)
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
            
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
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
                places.append(["name":title,"lat":"\(newCoordinate.latitude)","lon":"\(newCoordinate.longitude)"])
                
                let carParkingLocation = PFObject(className: "car")
                
                let point = PFGeoPoint(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
                
                let user = PFUser.currentUser()
                
                var uId = ""
                
                if let userId = user?.objectId {
                    uId = userId
                } else {
                    
                }
                
                carParkingLocation["location"] = point
                carParkingLocation["UserobjectId"] = uId
                carParkingLocation["name"] = title
                
                carParkingLocation.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        print("save success")
                    } else {
                        print("Failt")
                    }
                })
                
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
        
        //print(locations)
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let latitude  = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        //let location = CLLocation(latitude: latitude, longitude: longitude)
        
        
        let latDelta:CLLocationDegrees = 0.001
        let lonDelta:CLLocationDegrees = 0.001
        
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        // Commented out the below code so we can scroll around on the map.
        
        //self.map.setRegion(region, animated: true)
        
//        let annotation = MKPointAnnotation()
//        
//        annotation.coordinate = coordinate
//        
//        map.addAnnotation(annotation)
        
        latLocal = latitude
        lonLocal = longitude
        
//        print(latLocal)
//        print(lonLocal)
        
    }
    
    func indicateParkingLocation(latitude:Double, longitude:Double){
        
        
        let point = PFGeoPoint(latitude: latitude, longitude: longitude)
        
        let openParkingLocation = PFObject(className: "spot")
        
        let user = PFUser.currentUser()
        
        var uId = ""
        
        if let userId = user?.objectId {
            uId = userId
        } else {
            
        }
        
        openParkingLocation["location"] = point
        openParkingLocation["userId"] = uId
        
        openParkingLocation.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                print("save success")
            } else {
                print("Failt")
            }
        })

        
    }

    
    
    
    func saveLocation(latitude:Double, longitude:Double) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        
        if saveCheck == true {
            
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
                
                
                let carParkingLocation = PFObject(className: "car")
                
                let point = PFGeoPoint(latitude: latitude, longitude: longitude)
                
                let user = PFUser.currentUser()
                
                var uId = ""
                
                if let userId = user?.objectId {
                    uId = userId
                } else {
                    
                }
                
                carParkingLocation["location"] = point
                carParkingLocation["UserobjectId"] = uId
                carParkingLocation["name"] = title
                
                carParkingLocation.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        print("save success")
                    } else {
                        print("Failt")
                    }
                })
                
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = coordinate
                
                annotation.title = title
                
                self.map.addAnnotation(annotation)
                
                self.saveCheck = false
                print(places)
                
                let latDelta:CLLocationDegrees = 0.0008
                let lonDelta:CLLocationDegrees = 0.0008
                
                let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
                let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
                
                self.map.setRegion(region, animated: true)
                
            })
            
        }
    }


    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view"
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
            let ind = places.count - 1
            //print(places[places.count-1]["name"])
            
            let lat = Double(places[ind]["lat"]!)
            let lon = Double(places[ind]["lon"]!)
            
            // Upload to Parse class name "spot"
            let spotReport = PFObject(className: "spot")
            
            let point = PFGeoPoint(latitude: lat!, longitude: lon!)
            
            let user = PFUser.currentUser()
            
            var uId = ""
            
            if let userId = user?.objectId {
                uId = userId
            } else {
                
            }
            
            spotReport["location"] = point
            spotReport["userId"] = uId
            
            spotReport.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    print("save success")
                } else {
                    print("Failt")
                }
            })
            
        }
    }

    
    
    
    
}
