//
//  Recording+CoreDataProperties.swift
//  Name Your Key
//
//  Created by Paul Crompton on 2/6/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData


extension Recording {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording");
    }

    @NSManaged public var url: String?
    @NSManaged public var dateCreated: NSDate?
    @NSManaged public var key: String?
    @NSManaged public var title: String?

}
