//
//  ViewController.swift
//  Atoms
//
//  Created by Robert Brown on 3/10/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {
    
    weak var tableView: UITableView?
    weak var collectionView: UICollectionView?
    weak var searchBar: UISearchBar?
    var words: [String] = []
    var rootDataSource: ChainableDataSource?
    var filterDataSource: FilterableDataSource?
    var reorderDataSource: ReorderableDataSource?
    var indexDataSource: IndexableDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // From: /usr/share/dict/words
        let path = NSBundle.mainBundle().pathForResource("words.txt", ofType: nil)!
        let data = NSData(contentsOfFile: path)!
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)
        words = string?.componentsSeparatedByString("\n") as! [String]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView == nil && collectionView == nil {
            updateDataSource(false, useFilter: false, useReorder: false, useIndex: false)
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView?.setEditing(editing, animated: animated)
        tableView?.reloadData()
    }
    
    // MARK: Helpers
    // Lots of code here to dynamically adapt to any combination of chains.
    // Normally this setup won't be as long.
    
    private func updateDataSource(useCollectionView: Bool, useFilter: Bool, useReorder: Bool, useIndex: Bool) {
        clearDataSources()
        setUpUI(useCollectionView, useFilter, useReorder)
        setUpRoot()
        setUpIndex(useIndex)
        setUpReorder(useReorder)
        setUpFilter(useFilter)
        
        let dataSource = leafDataSource()
        tableView?.dataSource = dataSource
        collectionView?.dataSource = dataSource
        
        dataSource.registerForChanges() {
            self.tableView?.reloadData()
            self.collectionView?.reloadData()
        }
        
        tableView?.reloadData()
        collectionView?.reloadData()
    }
    
    private func setUpUI(useCollectionView: Bool, _ useFilter: Bool, _ useReorder: Bool) {
        tableView?.removeFromSuperview()
        collectionView?.removeFromSuperview()
        
        if useCollectionView {
            setUpCollectionView(useFilter)
        }
        else {
            setUpTableView(useFilter, useReorder)
        }
    }
    
    private func setUpTableView(useFilter: Bool, _ useReorder: Bool) {
        let tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.delegate = self
        self.view.addSubview(tableView)
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
        self.tableView = tableView
        
        if useFilter {
            let height = 44 as CGFloat
            let width = CGRectGetWidth(self.view.frame)
            let searchBar = UISearchBar(frame: CGRectMake(0, 0, width, height))
            searchBar.placeholder = "Filter"
            searchBar.delegate = self
            tableView.tableHeaderView = searchBar
            self.searchBar = searchBar
        }
        
        if useReorder {
            self.navigationItem.rightBarButtonItem = self.editButtonItem()
        }
        else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func setUpCollectionView(useFilter: Bool) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(150, 50)
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 0, 20)
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.view.addSubview(collectionView)
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
        self.collectionView = collectionView
        
        if useFilter {
            let height = 44 as CGFloat
            let width = CGRectGetWidth(self.view.frame)
            let searchBar = UISearchBar(frame: CGRectMake(0, 0, width, height))
            searchBar.placeholder = "Filter"
            searchBar.delegate = self
            searchBar.setTranslatesAutoresizingMaskIntoConstraints(false)
            collectionView.addSubview(searchBar)
            self.view.addSubview(searchBar)
            self.searchBar = searchBar
            self.view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: height))
            self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: searchBar, attribute: .Bottom, multiplier: 1, constant: 0))
        }
        else {
            self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        }
    }
    
    private func setUpRoot() {
        rootDataSource = ChainableDataSource([words]) { (view, indexPath, word) -> Any in
            if let word = word as? String {
                if let tableView = view as? UITableView {
                    return WordCell.cell(tableView, word: word)
                }
                else if let collectionView =  view as? UICollectionView {
                    return WordCollectionCell.cell(collectionView, indexPath: indexPath, word: word)
                }
            }
            
            fatalError("Unknown view: \(view)")
        }
    }
    
    private func setUpIndex(use: Bool) {
        if use == false {
            return
        }
        
        indexDataSource = IndexableDataSource(leafDataSource(), indexedSelector: "self")
    }
    
    private func setUpReorder(use: Bool) {
        if use == false {
            return
        }
        
        reorderDataSource = ReorderableDataSource(leafDataSource())
    }
    
    private func setUpFilter(use: Bool) {
        if use == false {
            return
        }
        
        filterDataSource = FilterableDataSource(leafDataSource()) { (query, collection) -> [[AnyObject]] in
            if let query = query as? String {
                if query == "" {
                    return collection
                }
                
                let normalizedQuery = query.lowercaseString
                
                return collection.map() { section in
                    return section.filter() {$0.lowercaseString.hasPrefix(normalizedQuery)}
                }
            }
            
            return collection
        }
    }
    
    private func clearDataSources() {
        rootDataSource = nil
        filterDataSource = nil
        reorderDataSource = nil
        indexDataSource = nil
    }
    
    private func leafDataSource() -> ChainableDataSource {
        return filterDataSource ?? reorderDataSource ?? indexDataSource ?? rootDataSource!
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        if let options = segue.sourceViewController as? OptionTableViewController {
            let useCollectionView = options.collectionViewSwitch.on
            let useFilter = options.filterSwitch.on
            let useReorder = options.reorderSwitch.on
            let useIndex = options.indexSwitch.on
            updateDataSource(useCollectionView, useFilter: useFilter, useReorder: useReorder, useIndex: useIndex)
        }
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filterDataSource?.context = ""
        }
        
        self.setEditing(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        filterDataSource?.context = searchBar.text
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
}

