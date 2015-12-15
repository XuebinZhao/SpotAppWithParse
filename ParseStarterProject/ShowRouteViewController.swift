//
//  ShowRouteViewController.swift
//  SpotAppParse
//
//  Created by xbin on 12/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MapKit

class ShowRouteViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    var destination = MKMapItem?()
    var manager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.map.showsUserLocation = true
        // **********************************************************************
        // code for route direction
        let latitude  = NSString(string: places[activePlace]["lat"]!).doubleValue
        let longitude = NSString(string: places[activePlace]["lon"]!).doubleValue
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        
        let latDelta:CLLocationDegrees = 0.05
        
        let lonDelta:CLLocationDegrees = 0.05
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        self.map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        annotation.title = places[activePlace]["name"]
        
        self.map.addAnnotation(annotation)
        
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
    
    // **********************************************************************
    func showRoute(response:MKDirectionsResponse) {
        for route in response.routes {
            map.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            
            for step in route.steps {
                print(step.instructions)
//                var subString: String
//                if step.instructions.hasPrefix("Proceed"){}
//                if step.instructions.hasPrefix("Arrive"){}
//                if step.instructions.hasPrefix("The destination"){}
//                if step.instructions.hasPrefix("Make a U-turn at")
//                {
//                    subString = step.instructions
//                    subString = subString.stringByReplacingOccurrencesOfString("Make a U-turn at ", withString: "")
//                    print(subString)
//                }
//                if step.instructions.hasPrefix("Turn right onto ")
//                {
//                    subString = step.instructions
//                    subString = subString.stringByReplacingOccurrencesOfString("Turn right onto ", withString: "")
//                    print(subString)
//                }
//                if step.instructions.hasPrefix("Turn left onto ")
//                {
//                    subString = step.instructions
//                    subString = subString.stringByReplacingOccurrencesOfString("Turn left onto ", withString: "")
//                    print(subString)
//                }
                
            }
        }
//                let region = MKCoordinateRegionMakeWithDistance(userLocation!.coordinate, 2000, 2000)
//                map.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    // **********************************************************************

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
