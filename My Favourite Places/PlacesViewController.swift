//
//  PlacesViewController.swift
//  My Favourite Places
//
//  Created by Na'Eem Auckburally on 17/11/2016.
//  Name: Na'eem Auckburally
//  ID: 201011641
//  Copyright © 2016 Na'Eem Auckburally. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation
var places = [Dictionary<String, String>()]         //Places array to hold info on places
var currentPlace = -1
var centre = 0                                      //Centre variable to know if the map should be centred by GPS

class PlacesViewController: UITableViewController, CLLocationManagerDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    var locationManager: CLLocationManager!
    var currentLatitude: Double?                  //Coordinates to store the users location
    var currentLongitude: Double?
    var distances: [Double] = []
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //Check if the location services is enabled
        
        //Getting the users current location, so that the distance can be calculated from here
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()                           //Location manager setup to get the users current location
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    //Method to populate the tables cells with information
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.showsReorderControl = true
        //Checks if the places array entry is not empty
        if places[indexPath.row]["name"] != nil {
            cell.textLabel?.text = places[indexPath.row]["name"]    //Then adds the name of the place from the places array
            print(places[indexPath.row]["name"])
            print(places[indexPath.row]["lat"])
            print(places[indexPath.row]["long"])
        }
        return cell
    }
 
    //When a cell in the table is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentPlace = indexPath.row                        //Get the index of the table entry
        centre = 0
        performSegue(withIdentifier: "Map", sender: nil)    //Segue to the map view
        print("Table method")
        print("Table method")
        print("Table method")
        
    }
    
    //When edit button is pressed
    @IBAction func startEdit(_ sender: AnyObject) {
        self.table.isEditing = !self.table.isEditing    //Turn editing on/off    
    }
    
    //Method to allow the table to have movable rows
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //Method for when the reorder button is used on a row
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = places[sourceIndexPath.row]                //Get the item that has been selected to move
        places.remove(at: sourceIndexPath.row)                      //Remove from places array
        places.insert(itemToMove, at: destinationIndexPath.row)     //Put in new position
        
        deleteData()            //Delete core data by calling function
        writeData()             //Resave core data using the new order after the editing by calling function
    }
    
    override func viewDidAppear(_ animated: Bool) {
        readData()
    }
    
    
    //Function handles when the user swipes and deletes the row
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //Check if the delete action has been performed
        if editingStyle == UITableViewCellEditingStyle.delete {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")      //Set up the request to get the data from the core data
            //look for username=a string, where the string is not empty.
            do {
                let results = try getContext().fetch(request)                               //Get the core data using the request
                
                //Check if there are results
                var counter = 0                 //Counter to track which item in the core data we are looking at
                if (results.count) > 0 {
                    for item in results as! [NSManagedObject]{                              //Loop for each result in the data
                        //Check if current item is same as the selected
                        if counter == indexPath.row{            //Check if its the same as the data of the one chosen to be deleted by comparing the selected item to the table row
                            //Delete the item
                            getContext().delete(item)                       //Delete this item
                            //Save the data
                            try getContext().save()                         //Then save the data
                        }
                        counter = counter + 1                               //Increment counter at end of loop
                    }
                }
            } catch {
                //If it cant get the results
                print("Couldn't fetch results")
            }
            
            places.remove(at: indexPath.row)                                                    //Remove the entry from the array
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)      //Delete the row in the table
            print("deleted")
            readData()                                                                          //Reload data from core data by calling function
            
            
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    //Function to handle when the add button is pressed
    @IBAction func plusButton(_ sender: AnyObject) {
        print("plus button")
        centre = 1                                         //Notify that it should centre by GPS by changing value of variable
        performSegue(withIdentifier: "Map", sender: nil)   //Segue to the map view
    }
    
    //Function to write the data from the places array into the core data
    func writeData() {
        //For each entry in the places array
        for counter in 0...(places.count - 1) {
            //Set up the core data settings
            let context = self.getContext()
            let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)     //Get the core data entity
            let data = NSManagedObject(entity: entity!, insertInto: context)
            data.setValue(places[counter]["name"], forKey: "name")                            //Set the information (name, long, lat) to the attributes of the entity
            data.setValue(places[counter]["lat"], forKey: "lat")
            data.setValue(places[counter]["long"], forKey: "long")
            do {
                try context.save()
                print("saved")                                      //Save the data
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
                
            } catch {
            }
        }
    }
    
    //Function to read the data in from the core data to the places array
    func readData(){
        places.removeAll()                                                          //Remove all entries from the places array
        centre = 0
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()        //Setup request for core data
        do {
            let searchResults = try getContext().fetch(fetchRequest)            //Get the results using the request
            //labelOutlet.text = searchResults[0].value(forKey: "choice") as? String
            if (searchResults.count == 0) {
                print("no data")
            }
            //Loop for each item in the results from core data
            for counter in searchResults as [NSManagedObject] {
                print("\(counter.value(forKey: "name"))")
                //Get and add to an entry in the places array, all the information for the current item
                places.append(["name":counter.value(forKey: "name") as! String, "lat": counter.value(forKey: "lat") as! String, "long": counter.value(forKey: "long") as! String])
                
            }
        } catch {
            print("Error with request: \(error)")
        }
        currentPlace = -1           //Reload data
        table.reloadData()
    }
  
    
    //Function to delete all the data in core data
    func deleteData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")          //Setup the request for the Location entity
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        do{
            try getContext().execute(delete)                                                //Delete all entries in the entity
            print("deleted")
        } catch{
            print("error")
        }
    }
    
    //Function for when the users location is retrieved
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation        //Get the last location of the user
        manager.stopUpdatingLocation()
        currentLatitude = location.coordinate.latitude      //Get the long and lat from the coordinates and assign this to 2 variables
        currentLongitude = location.coordinate.longitude
        print(currentLatitude)                              //Testing
        print(currentLongitude)
        
    }
    
    //Function to sort the places in the table by distance to the users current location
    func sort(){
        //Check if there is no data
        if (places.count == 0)
        {
            //Alert controller saying no data to sort
            let alert = UIAlertController(title: "Error", message: "No data in the table that can be sorted", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            
            
            distances.removeAll()                           //Remove all entries in the distance array
            let radius = 6371                               //Set radius of earth for calculating distance
            
            //For loop from 0 to the number of places in the places array
            for counter in 0...(places.count - 1){
                //Calculations to work out distance
                let dLat = self.degreesToRadians(degrees: Double(places[counter]["lat"]!)! - currentLatitude!)
                let dLong = self.degreesToRadians(degrees: Double(places[counter]["long"]!)! - currentLongitude!)
                let a = sin(dLat/2) * sin(dLat/2) + cos(self.degreesToRadians(degrees: Double(places[counter]["lat"]!)!)) * sin(dLong/2) * sin(dLong/2)
                let b = 2 * atan2(sqrt(a), sqrt(1-a))
                let distance = ((Double(radius) * b) * 0.62137)             //Convert distance to miles from km's
                distances.append(distance)                                  //Add the distance to the distances array
            }
            
            
            let zippedArrays = zip(places, distances).sorted {$0.1 < $1.1}      //Zip the 2 arrays of places and distances together and sort by ascending order
            places = zippedArrays.map {$0.0}                                    //Seperate out the zipped array to the indiviual array of places
            let sortedArrayDistances = zippedArrays.map {$0.1}                  //Seperate out the zipped array to the indiviual array of distances
            print(places)
            print(sortedArrayDistances)                                         //Testing method has worked
            
            deleteData()                          //Call the delete function
            writeData()                           //Save the modified data to the core data, so that the ordering by distance is now saved
            readData()                            //Reload the data into the table
        }
        
    }
    
    //Handles when the sort button is pressed
    @IBAction func sortButton(_ sender: AnyObject) {
        sort()
    }
    //Method convert from degrees to radians for the distance calculation
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
