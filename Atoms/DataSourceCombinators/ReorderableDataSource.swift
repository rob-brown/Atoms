//
//  ReorderableDataSource.swift
//  Atoms
//
//  Created by Robert Brown on 3/17/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

public class ReorderableDataSource: ChainableDataSource {
    
    init(_ dataSource: ChainableDataSource) {
        super.init(dataSource.collection, cellCreator: dataSource.cellCreator)
        self.dataSource = dataSource
        dataSource.registerForChanges() {
            self.update()
        }
    }
    
    // MARK: UITableViewDataSource
    
    public override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    public override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    public override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        move(from: sourceIndexPath, to: destinationIndexPath)
    }
    
    // MARK: Helpers
    
    private func update() {
        collection = dataSource!.collection
    }
}
