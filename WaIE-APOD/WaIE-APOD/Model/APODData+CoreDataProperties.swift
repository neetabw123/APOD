//
//  APODData+CoreDataProperties.swift
//  
//
//  Created by Kibbcom India on 26/11/22.
//
//

import Foundation
import CoreData


extension APODData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<APODData> {
        return NSFetchRequest<APODData>(entityName: "APODData")
    }

    @NSManaged public var date: String?
    @NSManaged public var explanation: String?
    @NSManaged public var hdurl: String?
    @NSManaged public var title: String?

}
