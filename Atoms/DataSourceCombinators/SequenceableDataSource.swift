////
////  SequenceableDataSource.swift
////  Atoms
////
////  Created by Robert Brown on 3/24/15.
////  Copyright (c) 2015 Robert Brown. All rights reserved.
////
//
//import UIKit
//
//public class SequenceableDataSource: NSObject, UITableViewDataSource, UICollectionViewDataSource {
//    
//    public typealias Element = AnyObject
//    
//    internal var dataSource: BaseDataSource
//    internal var nextDataSource: BaseDataSource?
//    
//    init(dataSource: BaseDataSource, next: BaseDataSource?) {
//        self.dataSource = dataSource
//        self.nextDataSource = next
//    }
//    
//    // MARK: UITableViewDataSource
//    
//    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        return dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
//    }
//    
//    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataSource.tableView(tableView, numberOfRowsInSection: section)
//    }
//    
//    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return dataSource.numberOfSectionsInTableView(tableView)
//    }
//    
//    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [Element]! {
//        if let result = dataSource.sectionIndexTitlesForTableView?(tableView) {
//            return result
//        }
//        else if let result = nextDataSource?.sectionIndexTitlesForTableView?(tableView) {
//            return result
//        }
//        
//        return []
//    }
//    
//    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
//        if let result = dataSource.tableView?(tableView, sectionForSectionIndexTitle: title, atIndex: index) {
//            return result
//        }
//        else if let result = nextDataSource?.tableView?(tableView, sectionForSectionIndexTitle: title, atIndex: index) {
//            return result
//        }
//        
//        return 0
//    }
//    
//    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if let result = dataSource.tableView?(tableView, titleForHeaderInSection: section) {
//            return result
//        }
//        else if let result = nextDataSource?.tableView?(tableView, titleForHeaderInSection: section) {
//            return result
//        }
//        
//        return nil
//    }
//    
//    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        if let result = dataSource.tableView?(tableView, titleForFooterInSection: section) {
//            return result
//        }
//        else if let result = nextDataSource?.tableView?(tableView, titleForFooterInSection: section) {
//            return result
//        }
//        
//        return nil
//    }
//    
//    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        if let result = dataSource.tableView?(tableView, canEditRowAtIndexPath: indexPath) {
//            return result
//        }
//        else if let result = nextDataSource?.tableView?(tableView, canEditRowAtIndexPath: indexPath) {
//            return result
//        }
//        
//        return false
//    }
//    
//    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        if let result = dataSource.tableView?(tableView, canMoveRowAtIndexPath: indexPath) {
//            return result
//        }
//        else if let result = nextDataSource?.tableView?(tableView, canMoveRowAtIndexPath: indexPath) {
//            return result
//        }
//        
//        return false
//    }
//    
//    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        dataSource.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
//        nextDataSource?.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
//    }
//    
//    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
//        dataSource.tableView?(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
//        nextDataSource?.tableView?(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
//    }
//    
//    // MARK: UICollectionViewDataSource
//    
////    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        
////    }
////    
////    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
////        
////    }
////    
////    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
////        
////    }
////    
////    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
////        
////    }
//}
