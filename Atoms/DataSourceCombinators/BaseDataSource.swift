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

open class BaseDataSource: NSObject, UITableViewDataSource, UICollectionViewDataSource {
    public typealias Element = AnyObject
    public typealias CellCreator = ((Any, IndexPath, Element) -> Any)
    public typealias SupplementCreator = ((Any, IndexPath, String) -> Any)
    public typealias ChangeUpdater = (()->())
    
    open var cellCreator: CellCreator
    open var collection: [[Element]] = [[]] {
        didSet(oldValue) {
            notify()
        }
    }
    fileprivate var updateClosures: [ChangeUpdater] = []
    
    public init(_ collection: [[Element]], cellCreator: @escaping CellCreator) {
        self.collection = collection
        self.cellCreator = cellCreator
    }
    
    open func registerForChanges(_ closure: @escaping ChangeUpdater) {
        updateClosures += [closure]
    }
    
    // MARK: Collection Management
    
    open func lookUp(_ indexPath: IndexPath) -> Element {
        return collection[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
    }
    
    open func remove(_ indexPath: IndexPath) -> Element {
        return collection[(indexPath as NSIndexPath).section].remove(at: (indexPath as NSIndexPath).row)
    }
    
    open func insert(_ object: Element, indexPath: IndexPath) {
        return collection[(indexPath as NSIndexPath).section].insert(object, at: (indexPath as NSIndexPath).row)
    }
    
    open func move(from: IndexPath, to: IndexPath) {
        let item: Element = remove(from)
        insert(item, indexPath: to)
    }
    
    // MARK: UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return self.collection.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collection[section].count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object: Element = lookUp(indexPath)
        return self.cellCreator(tableView, indexPath, object) as! UITableViewCell
    }
    
    // MARK: UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.collection.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collection[section].count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object: Element = lookUp(indexPath)
        return self.cellCreator(collectionView, indexPath, object) as! UICollectionViewCell
    }
    
    // MARK: Helpers
    
    fileprivate func notify() {
        for closure in updateClosures {
            closure()
        }
    }
}
