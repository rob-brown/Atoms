//
//  ViewController.swift
//  Atoms
//
//  Created by Robert Brown on 3/10/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {
    
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
        
        updateDataSource(false, useFilter: false, useReorder: false, useIndex: false)
    }
    
    // MARK: Helpers
    // Lots of code here to dynamically adapt to any combination of chains.
    // Normally this setup won't be as long.
    
    private func updateDataSource(useCollectionView: Bool, useFilter: Bool, useReorder: Bool, useIndex: Bool) {
        
        clearDataSources()
        setUpUI(useCollectionView, useFilter)
        setUpRoot()
        setUpIndex(useIndex)
        setUpFilter(useFilter)
        setUpReorder(useReorder)
        
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
    
    private func setUpUI(useCollectionView: Bool, _ useFilter: Bool) {
        
        // TODO: Handle the search bar here.
        
        tableView?.removeFromSuperview()
        collectionView?.removeFromSuperview()
        
        if useCollectionView {
            setUpCollectionView()
        }
        else {
            setUpTableView()
        }
    }
    
    private func setUpTableView() {
        let tableView = UITableView(frame: CGRectZero, style: .Plain)
        self.view.addSubview(tableView)
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
        self.tableView = tableView
    }
    
    private func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(150, 50)
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20)
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.view.addSubview(collectionView)
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0))
        self.collectionView = collectionView
    }
    
    private func setUpRoot() {
        rootDataSource = ChainableDataSource(collection: [words], cellCreator: { (view, indexPath, word) -> Any in
            if let word = word as? String {
                if let tableView = view as? UITableView {
                    return WordCell.cell(tableView, word: word)
                }
                else if let collectionView =  view as? UICollectionView {
                    return WordCollectionCell.cell(collectionView, indexPath: indexPath, word: word)
                }
            }
            
            fatalError("Unknown view: \(view)")
        })
    }
    
    private func setUpIndex(use: Bool) {
        if use == false {
            return
        }
        
        indexDataSource = IndexableDataSource(dataSource: leafDataSource(), indexedSelector: "self")
    }
    
    private func setUpReorder(use: Bool) {
        if use == false {
            return
        }
        
        reorderDataSource = ReorderableDataSource(dataSource: leafDataSource())
    }
    
    private func setUpFilter(use: Bool) {
        if use == false {
            return
        }
        
        let height = 44 as CGFloat
        let width = CGRectGetWidth(self.view.frame)
        let searchBar = UISearchBar(frame: CGRectMake(0, 0, width, height))
        searchBar.placeholder = "Filter"
        searchBar.delegate = self
        tableView?.tableHeaderView = searchBar
        collectionView?.addSubview(searchBar)
        collectionView?.contentInset = UIEdgeInsetsMake(height, 0, 0, 0)
        self.searchBar = searchBar
        filterDataSource = FilterableDataSource(dataSource: leafDataSource()) { (query, collection) -> [[AnyObject]] in
            if let query = query as? String {
                if query == "" {
                    return collection
                }
                
                var newSections = [[AnyObject]]()
                
                for list in collection {
                    var newRows = [AnyObject]()
                    
                    for word in list {
                        if let word = word as? String {
                            if word.hasPrefix(query) {
                                newRows += [word]
                            }
                        }
                    }
                    newSections += [newRows]
                }
                
                return newSections
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
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        filterDataSource?.context = searchBar.text
    }
}

