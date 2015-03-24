//
//  ChainableDataSource.swift
//  Atoms
//
//  Created by Robert Brown on 3/18/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

public class ChainableDataSource: BaseDataSource {
    
    internal var dataSource: ChainableDataSource?
    
    override init(_ collection: [[Element]], cellCreator: CellCreator) {
        super.init(collection, cellCreator: cellCreator)
    }
    
    // MARK: Forwarded UITableViewDataSource
    
    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [Element]! {
        if let dataSource = dataSource {
            return dataSource.sectionIndexTitlesForTableView(tableView)
        }
        
        return []
    }
    
    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
        }
        
        return 0
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let dataSource = dataSource {
            return dataSource.tableView(tableView, titleForHeaderInSection: section)
        }
        
        return nil
    }
    
    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let dataSource = dataSource {
            return dataSource.tableView(tableView, titleForFooterInSection: section)
        }
        
        return nil
    }
    
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let dataSource = dataSource {
            return dataSource.tableView(tableView, canEditRowAtIndexPath: indexPath)
        }
        
        return false
    }
    
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let dataSource = dataSource {
            return dataSource.tableView(tableView, canMoveRowAtIndexPath: indexPath)
        }
        
        return false
    }
    
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if let dataSource = dataSource {
            dataSource.tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
        }
    }
    
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if let dataSource = dataSource {
            dataSource.tableView(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
        }
    }
}
