//
//  BaseDataSource.swift
//  Atoms
//
//  Created by Robert Brown on 3/10/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

public class BaseDataSource: NSObject, UITableViewDataSource, UICollectionViewDataSource {
    public typealias CellCreator = ((Any, NSIndexPath, AnyObject) -> Any)
    public typealias SupplementCreator = ((Any, NSIndexPath, String) -> Any)
    public typealias ChangeUpdater = (()->())
    
    var cellCreator: CellCreator
    var collection: [[AnyObject]] = [[]] {
        didSet(oldValue) {
            notify()
        }
    }
    private var updateClosures: [ChangeUpdater] = []
    
    init(collection: [[AnyObject]], cellCreator: CellCreator) {
        self.collection = collection
        self.cellCreator = cellCreator
    }
    
    public func lookUpObject(indexPath: NSIndexPath) -> AnyObject {
        return collection[indexPath.section][indexPath.row]
    }
    
    public func registerForChanges(closure: ChangeUpdater) {
        updateClosures += [closure]
    }
    
    // MARK: UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(self.collection)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(self.collection[section])
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object: AnyObject = lookUpObject(indexPath)
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
        let object: AnyObject = lookUpObject(indexPath)
        return self.cellCreator(collectionView, indexPath, object) as! UICollectionViewCell
    }
    
    // MARK: Helpers
    
    private func notify() {
        for closure in updateClosures {
            closure()
        }
    }
}
