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

public class ChainableDataSource: BaseDataSource {
    public private(set) var dataSource: ChainableDataSource?
    
    override public init(_ collection: [[Element]], cellCreator: CellCreator) {
        super.init(collection, cellCreator: cellCreator)
    }
    
    public init(dataSource: ChainableDataSource) {
        self.dataSource = dataSource
        super.init(dataSource.collection, cellCreator: dataSource.cellCreator)
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
