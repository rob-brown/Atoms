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

public class IndexableDataSource: ChainableDataSource {
   
    private let indexedSelector: Selector
    
    public init(_ dataSource: ChainableDataSource, indexedSelector: Selector) {
        self.indexedSelector = indexedSelector
        super.init(dataSource: dataSource)
        collection = populate(dataSource.collection)
        dataSource.registerForChanges() {
            self.collection = self.populate(dataSource.collection)
        }
    }
    
    // MARK: UITableViewDataSource
    
    public override func sectionIndexTitlesForTableView(tableView: UITableView) -> [Element]! {
        return UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
    }
    
    public override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return UILocalizedIndexedCollation.currentCollation().sectionForSectionIndexTitleAtIndex(index)
    }
    
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return UILocalizedIndexedCollation.currentCollation().sectionTitles[section]
    }
    
    // MARK: Helpers
    
    private func populate(sections: [[Element]]) -> [[Element]] {
        
        // Uses ObjC mutable collections since Swift is too slow for large data sets.
        let count = UILocalizedIndexedCollation.currentCollation().sectionTitles.count
        let newSections = NSMutableArray(capacity: count)
        
        // Creates an array of empty mutable arrays.
        for _ in 0..<count {
            newSections.addObject(NSMutableArray())
        }
        
        // Puts all the objects in the right buckets.
        for list in sections {
            for object in list {
                let index = UILocalizedIndexedCollation.currentCollation().sectionForObject(object, collationStringSelector: indexedSelector)
                let targetList = newSections[index] as! NSMutableArray
                targetList.addObject(object)
            }
        }

        // Sorts the buckets.
        var swiftSections = [[Element]]()
        
        for index in 0..<count {
            let list = newSections[index] as! [Element]
            let sorted = UILocalizedIndexedCollation.currentCollation().sortedArrayFromArray(list, collationStringSelector: self.indexedSelector) as [Element]
            swiftSections += [sorted]
        }
        
        return swiftSections
    }
}
