//
//  FilterableDataSource.swift
//  Atoms
//
//  Created by Robert Brown on 3/17/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

public class FilterableDataSource: ChainableDataSource {
    
    public typealias Context = Element
    public typealias Filter = ((Context?, [[Element]]) -> [[Element]])
    
    var context: Context? = nil {
        didSet(oldValue) {
            update()
        }
    }
    private let filter: Filter
    
    init(_ dataSource: ChainableDataSource, filter: Filter) {
        self.filter = filter
        super.init(dataSource.collection, cellCreator: dataSource.cellCreator)
        self.dataSource = dataSource
        dataSource.registerForChanges() {
            self.update()
        }
    }
    
    // MARK: UITableViewDataSource
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return collection.count
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection[section].count
    }
    
    // MARK: UICollectionViewDataSource
    
    public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return collection.count
    }
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection[section].count
    }
    
    // MARK: Helpers
    
    private func update() {
        collection = filter(context, dataSource!.collection)
    }
}
