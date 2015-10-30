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

class NewMapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var manager: CLLocationManager!
    
    var saveCheck = false
    
//    var titleLocal = ""
    var latLocal:Double = 0.0
    var lonLocal:Double = 0.0
    
    @IBAction func refreshMap(sender: AnyObject) {
        let annotationsToRemove = map.annotations
        self.map.removeAnnotations(annotationsToRemove)
    }
    
    @IBAction func saveParkLocation(sender: AnyObject) {
        saveCheck = true
        self.saveLocation(latLocal, longitude: lonLocal)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.map.showsUserLocation = true

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
            
            self.map.addAnnotation(annotation)
            
          
            
        }
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
        
        uilpgr.minimumPressDuration = 1.0
        
        map.addGestureRecognizer(uilpgr)
        
        
    }
    
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
                
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = newCoordinate
                
                annotation.title = title
                
                self.map.addAnnotation(annotation)
                
            })
            
        }
    }
    


    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations)
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let latitude  = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        //let location = CLLocation(latitude: latitude, longitude: longitude)
        
        
        let latDelta:CLLocationDegrees = 0.01
        let lonDelta:CLLocationDegrees = 0.01
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        self.map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        map.addAnnotation(annotation)
        
        latLocal = latitude
        lonLocal = longitude
        print(latLocal)
        print(lonLocal)
        
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

    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOut()
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            logIn = false
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    
    
}
