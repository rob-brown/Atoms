//
//  BaseDataSource.swift
//  Atoms
//
//  Created by Robert Brown on 3/10/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

public class BaseDataSource: NSObject, UITableViewDataSource, UICollectionViewDataSource {
    public typealias Element = AnyObject
    public typealias CellCreator = ((Any, NSIndexPath, Element) -> Any)
    public typealias SupplementCreator = ((Any, NSIndexPath, String) -> Any)
    public typealias ChangeUpdater = (()->())
    
    var cellCreator: CellCreator
    var collection: [[Element]] = [[]] {
        didSet(oldValue) {
            notify()
        }
    }
    private var updateClosures: [ChangeUpdater] = []
    
    init(_ collection: [[Element]], cellCreator: CellCreator) {
        self.collection = collection
        self.cellCreator = cellCreator
    }
    
    public func registerForChanges(closure: ChangeUpdater) {
        updateClosures += [closure]
    }
    
    // MARK: Collection Management
    
    public func lookUp(indexPath: NSIndexPath) -> Element {
        return collection[indexPath.section][indexPath.row]
    }
    
    public func remove(indexPath: NSIndexPath) -> Element {
        return collection[indexPath.section].removeAtIndex(indexPath.row)
    }
    
    public func insert(object: Element, indexPath: NSIndexPath) {
        return collection[indexPath.section].insert(object, atIndex: indexPath.row)
    }
    
    public func move(#from: NSIndexPath, to: NSIndexPath) {
        let item: Element = remove(from)
        insert(item, indexPath: to)
    }
    
    // MARK: UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(self.collection)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(self.collection[section])
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object: Element = lookUp(indexPath)
        return self.cellCreator(tableView, indexPath, object) as! UITableViewCell
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return count(self.collection)
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count(self.collection[section])
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let object: Element = lookUp(indexPath)
        return self.cellCreator(collectionView, indexPath, object) as! UICollectionViewCell
    }
    
    // MARK: Helpers
    
    private func notify() {
        for closure in updateClosures {
            closure()
        }
    }
}
