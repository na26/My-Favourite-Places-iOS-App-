//
//  Location+CoreDataProperties.swift
//  My Favourite Places
//
//  Created by Na'Eem Auckburally on 22/11/2016.
//  Copyright © 2016 Na'Eem Auckburally. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var name: String?
    @NSManaged public var lat: String?
    @NSManaged public var long: String?

}
