//
//  DummyConversationModel.swift
//  rapidlyUpdatingTableView-Swift
//
//  Created by Matthew Keable on 23/05/2016.
//  Copyright © 2016 Matthew Keable. All rights reserved.
//

import UIKit
import CoreData

class DummyConversationModel: NSManagedObject {
    @NSManaged var titleText: String
    @NSManaged var dummyText: String
    @NSManaged var timeStamp: NSDate
    @NSManaged var sectionId: Int

}
