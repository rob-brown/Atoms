//
//  IndexableDataSource.swift
//  Atoms
//
//  Created by Robert Brown on 3/17/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

public class IndexableDataSource: ChainableDataSource {
   
    private let indexedSelector: Selector
    
    init(dataSource: ChainableDataSource, indexedSelector: Selector) {
        self.indexedSelector = indexedSelector
        super.init(collection: dataSource.collection, cellCreator: dataSource.cellCreator)
        self.dataSource = dataSource
        collection = populate(dataSource.collection)
        dataSource.registerForChanges() {
            self.collection = self.populate(dataSource.collection)
        }
    }
    
    // MARK: UITableViewDataSource
    
    public override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
    }
    
    public override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return UILocalizedIndexedCollation.currentCollation().sectionForSectionIndexTitleAtIndex(index)
    }
    
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return UILocalizedIndexedCollation.currentCollation().sectionTitles[section] as? String
    }
    
    // MARK: Helpers
    
    private func populate(sections: [[AnyObject]]) -> [[AnyObject]] {
        
        // Uses ObjC mutable collections since Swift is too slow for large data sets.
        let count = UILocalizedIndexedCollation.currentCollation().sectionTitles.count
        let newSections = NSMutableArray(capacity: count)
        
        // Creates an array of empty mutable arrays.
        for _ in 0..<count {
            newSections.addObject(NSMutableArray())
        }
        
        // Puts all the objects in the right buckets.
        for list in sections {
            for object in list {
                let index = UILocalizedIndexedCollation.currentCollation().sectionForObject(object, collationStringSelector: indexedSelector)
                let targetList = newSections[index] as! NSMutableArray
                targetList.addObject(object)
            }
        }

        // Sorts the buckets.
        var swiftSections = [[AnyObject]]()
        
        for index in 0..<count {
            let list = newSections[index] as! [AnyObject]
            let sorted = UILocalizedIndexedCollation.currentCollation().sortedArrayFromArray(list, collationStringSelector: self.indexedSelector) as [AnyObject]
            swiftSections += [sorted]
        }
        
        return swiftSections
    }
}
