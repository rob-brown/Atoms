//               ~MMMMMMMM,.           .,MMMMMMM ..
//              DNMMDMMMMMMMM,.     ..MMMMNMMMNMMM,
//              MMM..   ...NMMM    MMNMM       ,MMM
//             NMM,        , MMND MMMM          .MM
//             MMN             MMMMM             MMM
//            .MM           , MMMMMM ,           MMM
//            .MM            MMM. MMMM           MMM
//            .MM~         .MMM.   NMMN.         MMM
//             MMM        MMMM: .M ..MMM        .MM,
//             MMM.NNMMMMMMMMMMMMMMMMMMMMMMMMMM:MMM,
//         ,,MMMMMMMMMMMMMMM           NMMDNMMMMMMMMN~,
//        MMMMMMMMM,,  OMMM             NMM  . ,MMNMMMMN.
//     ,MMMND  .,MM=  NMM~    MMMMMM+.   MMM.  NMM. .:MMMMM.
//    MMMM       NMM,MMMD   MMM$ZZZMMM:  .NMN.MMM        NMMM
//  MMNM          MMMMMM   MMZO~:ZZZZMM~   MMNMMN         .MMM
//  MMM           MMMMM   MMNZ~~:ZZZZZNM,   MMMM            MMN.
//  MM.           .MMM.   MMZZOZZZZZZZMM.   MMMM            MMM.
//  MMN           MMMMN   MMMZZZZZZZZZNM.   MMMM            MMM.
//  NMMM         .MMMNMN  .MM$ZZZZZZZMMN ..NMMMMM          MMM
//   MMMMM       MMM.MMM~  .MNMZZZZMMMD   MMM MMM .    . NMMN,
//     NMMMM:  ..MM8  MMM,  . MNMMMM:   .MMM:  NMM  ..MMMMM
//     ...MMMMMMNMM    MMM      ..      MMM.    MNDMMMMM.
//        .: MMMMMMMMMMDMMND           MMMMMMMMNMMMMM
//             NMM8MNNMMMMMMMMMMMMMMMMMMMMMMMMMMNMM
//            ,MMM        NMMMDMMMMM NMM.,.     ,MM
//             MMO        ..MMM    NMMM          MMD
//            .MM.         ,,MMM+.MMMM=         ,MMM
//            .MM.            MMMMMM~.           MMM
//             MM=             MMMMM..          .MMN
//             MMM           MMM8 MMMN.          MM,
//             +MMO        MMMN,   MMMMM,       MMM
//             ,MMMMMMM8MMMMM,      . MMNMMMMMMMMM.
//               .NMMMMNMM              DMDMMMMMM

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var optionsButton: UIBarButtonItem?
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
        let path = Bundle.main.path(forResource: "words.txt", ofType: nil)!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        words = (string?.components(separatedBy: "\n"))!
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if tableView == nil && collectionView == nil {
            updateDataSource(false, useFilter: false, useReorder: false, useIndex: false)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView?.setEditing(editing, animated: animated)
        tableView?.reloadData()
    }
    
    // MARK: Helpers
    // Lots of code here to dynamically adapt to any combination of chains.
    // Normally this setup won't be as long.
    
    fileprivate func updateDataSource(_ useCollectionView: Bool, useFilter: Bool, useReorder: Bool, useIndex: Bool) {
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
    
    fileprivate func setUpUI(_ useCollectionView: Bool, _ useFilter: Bool, _ useReorder: Bool) {
        tableView?.removeFromSuperview()
        collectionView?.removeFromSuperview()
        
        if useCollectionView {
            setUpCollectionView(useFilter)
        }
        else {
            setUpTableView(useFilter, useReorder)
        }
    }
    
    fileprivate func setUpTableView(_ useFilter: Bool, _ useReorder: Bool) {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0))
        self.tableView = tableView
        
        if useFilter {
            let height = 44 as CGFloat
            let width = self.view.frame.width
            let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: width, height: height))
            searchBar.placeholder = "Filter"
            searchBar.delegate = self
            tableView.tableHeaderView = searchBar
            self.searchBar = searchBar
        }
        
        if let optionsButton = optionsButton {
            if useReorder {
                self.navigationItem.rightBarButtonItems = [editButtonItem, optionsButton]
            }
            else {
                self.navigationItem.rightBarButtonItems = [optionsButton]
            }
        }
    }
    
    fileprivate func setUpCollectionView(_ useFilter: Bool) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 50)
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 0, 20)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.view.addSubview(collectionView)
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0))
        self.collectionView = collectionView
        
        if useFilter {
            let height = 44 as CGFloat
            let width = self.view.frame.width
            let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: width, height: height))
            searchBar.placeholder = "Filter"
            searchBar.delegate = self
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            collectionView.addSubview(searchBar)
            self.view.addSubview(searchBar)
            self.searchBar = searchBar
            self.view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0))
            self.view.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
            self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: searchBar, attribute: .bottom, multiplier: 1, constant: 0))
        }
        else {
            self.view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        }
    }
    
    fileprivate func setUpRoot() {
        rootDataSource = ChainableDataSource([words as Array<AnyObject>]) { (view, indexPath, word) -> Any in
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
    
    fileprivate func setUpIndex(_ use: Bool) {
        if use == false {
            return
        }
        
        indexDataSource = IndexableDataSource(leafDataSource(), indexedSelector: "self")
    }
    
    fileprivate func setUpReorder(_ use: Bool) {
        if use == false {
            return
        }
        
        reorderDataSource = ReorderableDataSource(leafDataSource())
    }
    
    fileprivate func setUpFilter(_ use: Bool) {
        if use == false {
            return
        }
        
        filterDataSource = FilterableDataSource(leafDataSource()) { (query, collection) -> [[AnyObject]] in
            if let query = query as? String {
                if query == "" {
                    return collection
                }
                
                let normalizedQuery = query.lowercased()
                
                return collection.map() { section in
                    return section.filter() {$0.lowercased.hasPrefix(normalizedQuery)}
                }
            }
            
            return collection
        }
    }
    
    fileprivate func clearDataSources() {
        rootDataSource = nil
        filterDataSource = nil
        reorderDataSource = nil
        indexDataSource = nil
    }
    
    fileprivate func leafDataSource() -> ChainableDataSource {
        return filterDataSource ?? reorderDataSource ?? indexDataSource ?? rootDataSource!
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        if let options = segue.source as? OptionTableViewController {
            let useCollectionView = options.collectionViewSwitch.isOn
            let useFilter = options.filterSwitch.isOn
            let useReorder = options.reorderSwitch.isOn
            let useIndex = options.indexSwitch.isOn
            updateDataSource(useCollectionView, useFilter: useFilter, useReorder: useReorder, useIndex: useIndex)
        }
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            filterDataSource?.context = "" as FilterableDataSource.Context?
        }
        
        self.setEditing(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterDataSource?.context = searchBar.text as FilterableDataSource.Context?
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}

