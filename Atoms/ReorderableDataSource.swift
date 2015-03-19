//
//  ReorderableDataSource.swift
//  Atoms
//
//  Created by Robert Brown on 3/17/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

class ReorderableDataSource: ChainableDataSource {
    
    
    // TODO: 
    
    init(dataSource: ChainableDataSource) {
        super.init(collection: dataSource.collection, cellCreator: dataSource.cellCreator)
        self.dataSource = dataSource
        dataSource.registerForChanges() {
//            self.update()
        }
    }
    
}
