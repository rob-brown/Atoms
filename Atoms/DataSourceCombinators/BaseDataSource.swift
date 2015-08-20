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
    
    public func move(from from: NSIndexPath, to: NSIndexPath) {
        let item: Element = remove(from)
        insert(item, indexPath: to)
    }
    
    // MARK: UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.collection.count
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collection[section].count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object: Element = lookUp(indexPath)
        return self.cellCreator(tableView, indexPath, object) as! UITableViewCell
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.collection.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collection[section].count
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
