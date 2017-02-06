//
//  Recording+CoreDataClass.swift
//  Name Your Key
//
//  Created by Paul Crompton on 2/2/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import Foundation
import CoreData

@objc(Recording)
public class Recording: NSManagedObject {

    convenience init(title: String?, key: String, url: URL, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Recording", in: context) {
            self.init(entity: ent, insertInto: context)
            self.title = title
            self.key = key
            self.url = url.absoluteString
            self.dateCreated = NSDate()
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
