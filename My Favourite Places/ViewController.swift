//
//  ViewController.swift
//  My Favourite Places
//
//  Created by Na'Eem Auckburally on 17/11/2016.
//  Name: Na'eem Auckburally
//  ID: 201011641
//  Copyright © 2016 Na'Eem Auckburally. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var map: MKMapView!                          //Outlet for the map
    @IBOutlet weak var segControlOutlet: UISegmentedControl!    //Outlet for the segmented control
    
    var locationManager: CLLocationManager!                     //Location manager for GPS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Checks if the map should go to the users current location based on the value of the variable
        if(centre == 1)
        {
            if (CLLocationManager.locationServicesEnabled())
            {
                locationManager = CLLocationManager()                           //Location manager setup to get the users current location
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()                    //Get authorisation
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
            }
        }
            
            //Otherwise, check if a place has been selected from the table
        else {
            //Check that there are places to add
            if currentPlace != -1 {
                if places.count > currentPlace {
                    if let name = places[currentPlace]["name"] {                //Get the name from the array
                        if let lat = places[currentPlace]["lat"] {              //Get the latitude from the array
                            if let lon = places[currentPlace]["long"] {         //Get the longitude from the array
                                if let latitude = Double(lat) {
                                    if let longitude = Double(lon) {
                                        let span = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)             //Set the span of the map
                                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)   //Set the coordinate up using the current places long and lat
                                        let region = MKCoordinateRegion(center: coordinate, span: span)         //Set the region
                                        self.map.setRegion(region, animated: true)
                                        let annotation = MKPointAnnotation()            //Create annotation
                                        annotation.coordinate = coordinate              //Set the coordinate and title of the annotation
                                        annotation.title = name
                                        self.map.addAnnotation(annotation)              //Add the annotation to the map
                                    } }
                            } }
                    } }
            }
        }
        print(currentPlace)
        let uilpgr = UILongPressGestureRecognizer(target: self, action:         //Create the gesture recognizer for a long press
            #selector(ViewController.longpress(gestureRecognizer:)))
        uilpgr.minimumPressDuration = 2                                         //Duration of long press
        map.addGestureRecognizer(uilpgr)                                        //Add the recogniser to the map
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function to handle the long press
    func longpress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            print("===\nLong Press\n===")
            let touchPoint = gestureRecognizer.location(in: self.map)
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)        //Get the coordinates from the map where the long press has been pressed
            print(newCoordinate)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude:
                newCoordinate.longitude)
            var title = ""
            CLGeocoder().reverseGeocodeLocation(location, completionHandler:        //Get the location from this coordinate
                { (placemarks, error) in
                    if error != nil {
                        print(error)
                    } else {
                        if let placemark = placemarks?[0] {
                            if placemark.subThoroughfare != nil {
                                title += placemark.subThoroughfare! + " "
                            }
                            if placemark.thoroughfare != nil {
                                title += placemark.thoroughfare!
                            }
                        } }
                    if title == "" {
                        title = "Added \(NSDate())"
                    }
                    let annotation = MKPointAnnotation()                    //Add annotation to the map
                    annotation.coordinate = newCoordinate
                    annotation.title = title
                    self.map.addAnnotation(annotation)
                    places.append(["name":title, "lat": String(newCoordinate.latitude),         //Add the new location's information to the places array
                                   "long": String(newCoordinate.longitude)])
                    let context = self.getContext()
                    let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)     //Get the core data entity
                    let data = NSManagedObject(entity: entity!, insertInto: context)
                    data.setValue(title, forKey: "name")                            //Set the information (name, long, lat) to the attributes of the entity
                    data.setValue(String(newCoordinate.latitude), forKey: "lat")
                    data.setValue(String(newCoordinate.longitude), forKey: "long")

                    do {
                        try context.save()
                        print("saved")                                      //Save the data
                    } catch let error as NSError {
                        print("Could not save \(error), \(error.userInfo)")
                        
                    } catch {
                    }
                    
                    
                    
            }) }
    }

    //Function to get context for the core data
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    //Function to handle the location manager to get the users current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation        //Get the last location of the user
        manager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)   //Set the map settings based on this coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        let annotation = MKPointAnnotation()            //Setup an annotation with the info
        annotation.coordinate = location.coordinate
        annotation.title = "Current Location"
        self.map.addAnnotation(annotation)              //Add the annotation to the map
        
        self.map.setRegion(region, animated: true)      //Set the region of the map
    }
    
    
    //Function which handles when the segmented control is changed
    @IBAction func segControlAction(_ sender: AnyObject) {
        switch segControlOutlet.selectedSegmentIndex
        {
        case 0:
             self.map.mapType = MKMapType.standard                       //Change the map type to standard
        case 1:
            self.map.mapType = MKMapType.satellite                      //Change the map type to satellite
        case 2:
            self.map.mapType = MKMapType.hybrid                         //Change the map type to hybrid
        default:
            break
        }
        
        
    }
    

}

