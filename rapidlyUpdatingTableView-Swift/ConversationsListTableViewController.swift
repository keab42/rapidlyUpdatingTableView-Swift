//
//  ConversationsListTableViewController.swift
//  rapidlyUpdatingTableView-Swift
//
//  Created by Matthew Keable on 23/05/2016.
//  Copyright © 2016 Matthew Keable. All rights reserved.
//

import UIKit
import CoreData

class ConversationsListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var updatesPerMinute: Int?
    var sectionData: [Int]?
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        let coordinator = self.persistentStoreCoordinator
        let _managedObjectContext = NSManagedObjectContext.init(concurrencyType: .MainQueueConcurrencyType)
        _managedObjectContext.persistentStoreCoordinator = coordinator
        
        return _managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
        
        let storeURL = documentsURL?.URLByAppendingPathComponent("rapidlyUpdatingTable.sqlite")
        
        do {
            // Add Persistent Store to Persistent Store Coordinator
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            
        } catch {
            print("MKTEST - Error with saved data")
            
            abort()
        }
        
        return persistentStoreCoordinator
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("rapidlyUpdatingTableView_Swift", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        
        let fetchRequest = NSFetchRequest.init()
        let entity = NSEntityDescription.entityForName("DummyConversation", inManagedObjectContext: self.managedObjectContext)
        
        fetchRequest.entity = entity
        
        let sort = NSSortDescriptor.init(key: "timeStamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sort]
        
        let theFetchedResultsController = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "sectionId", cacheName: nil)
        
        theFetchedResultsController.delegate = self
        
        return theFetchedResultsController
    }()
    
    
    // Declare some collection properties to hold the various updates we might get from the NSFetchedResultsControllerDelegate
    lazy var deletedSectionIndexes: NSMutableIndexSet = {
        return NSMutableIndexSet()
    }()
    
    lazy var insertedSectionIndexes: NSMutableIndexSet = {
        return NSMutableIndexSet()
    }()
    
    lazy var deletedRowIndexPaths: [NSIndexPath] = {
        return []
    }()
    
    lazy var insertedRowIndexPaths: [NSIndexPath] = {
        return []
    }()
    
    lazy var updatedRowIndexPaths: [NSIndexPath] = {
        return []
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let secData = sectionData {
            do {
                try self.fetchedResultsController.performFetch()
                generateMessagesInSections(secData)
            } catch {
                let fetchError = error as NSError
                print("\(fetchError), \(fetchError.userInfo)")
            }
            self.tableView.reloadData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            print("MKTEST - \(sections.count)")
            return sections.count;
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dummyMessageCell", forIndexPath: indexPath) as! DummyMessageTableViewCell
        
        let model = fetchedResultsController.objectAtIndexPath(indexPath) as! DummyConversationModel
        
        cell.titleLabel.text = model.titleText
        cell.timestampLabel.text = "\(model.timeStamp)"
        
        return cell
    }
    
    // MARK: - Editing
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        var actions = [UITableViewRowAction]()
        
        let action1 = UITableViewRowAction.init(style: UITableViewRowActionStyle.Destructive, title: "Action1") { [weak self]  (action, indexPath) in
            print("MKTEST - Action1")
        }
        
        actions.append(action1)
        
        let action2 = UITableViewRowAction.init(style: UITableViewRowActionStyle.Default, title: "Action2") { [weak self] (action, indexPath) in
            print("MKTEST - Action2")
        }
        
        actions.append(action2)
        
        return actions
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //Need to implement the method to get editing to work, but don't need to actually do anything inside
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return tableView.editing ? UITableViewCellEditingStyle.None : UITableViewCellEditingStyle.Delete
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch (type) {
        case .Insert:
            insertedSectionIndexes.addIndex(sectionIndex)
            break;
        case .Delete:
            deletedSectionIndexes.addIndex(sectionIndex)
            break;
        default:
            // Shouldn't have a default
            break;
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if (type == .Insert)
        {
            if (insertedSectionIndexes.containsIndex(newIndexPath!.section)) {
                // If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
                return;
            }
            insertedRowIndexPaths.append(newIndexPath!)
        }
        else if (type == .Delete)
        {
            if (deletedSectionIndexes.containsIndex(indexPath!.section)) {
                // If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
                return;
            }
            
            deletedRowIndexPaths.append(indexPath!)
        }
        else if (type == .Move)
        {
            if !indexPath!.isEqual(newIndexPath!) || insertedSectionIndexes.count > 0 || deletedSectionIndexes.count > 0
            {
                if !insertedSectionIndexes.containsIndex(newIndexPath!.section) {
                    insertedRowIndexPaths.append(newIndexPath!)
                }
                
                if !deletedSectionIndexes.containsIndex(indexPath!.section) {
                    deletedRowIndexPaths.append(indexPath!)
                }
            }
        }
        else if (type == .Update)
        {
            if indexPath!.isEqual(newIndexPath)
            {
                updatedRowIndexPaths.append(indexPath!)
            }
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.deleteSections(deletedSectionIndexes, withRowAnimation: .Fade)
        self.tableView.insertSections(insertedSectionIndexes, withRowAnimation: .Fade)
        
        self.tableView.deleteRowsAtIndexPaths(deletedRowIndexPaths, withRowAnimation: .Fade)
        self.tableView.insertRowsAtIndexPaths(insertedRowIndexPaths, withRowAnimation: .Fade)
        self.tableView.reloadRowsAtIndexPaths(updatedRowIndexPaths, withRowAnimation: .None)
        self.tableView.endUpdates()
        
        insertedSectionIndexes = NSMutableIndexSet()
        deletedSectionIndexes = NSMutableIndexSet()
        deletedRowIndexPaths = []
        insertedRowIndexPaths = []
        updatedRowIndexPaths = []
    }
    
    // MARK: - Dummy Data Handling
    func generateMessagesInSections(numberOfItemsPerSection: NSArray) {
        //use an array as the argument here so we can expand this later if necessary
        
        //wipe previous data
        deleteAllMessages()
        
        //populate with new data
        let context = managedObjectContext
        for i in 0...numberOfItemsPerSection.count - 1 {
            let numberItems = numberOfItemsPerSection[i].intValue
            for j in 0...numberItems - 1 {
                print("MKTEST - i = \(i), j = \(j)")
                let model = NSEntityDescription.insertNewObjectForEntityForName("DummyConversation", inManagedObjectContext: context) as! DummyConversationModel
                model.titleText = "Section \(i), Cell \(j)"
                model.sectionId = Int32(i)
                model.timeStamp = NSDate()
            }
        }
        
        do {
            // Save Record
            try managedObjectContext.save()
            
            // Dismiss View Controller
            dismissViewControllerAnimated(true, completion: nil)
            
        } catch {
            let saveError = error as NSError
            print("MKTEST - \(saveError), \(saveError.userInfo)")
        }
    }
    
    func deleteAllMessages() {
        let context = managedObjectContext
        
        if let fetched = fetchedResultsController.fetchedObjects {
            for conv in fetched as! [DummyConversationModel]  {
                context.deleteObject(conv)
            }
        }
        
        do {
            // Save Record
            try context.save()
            
            // Dismiss View Controller
            dismissViewControllerAnimated(true, completion: nil)
            
        } catch {
            let saveError = error as NSError
            print("MKTEST - \(saveError), \(saveError.userInfo)")
        }
    }
    
    func updateMessages() {
        //TODO spawn a thread here that updates a random message on the frequency specified in the class.
    }
    
}
