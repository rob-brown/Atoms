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

class SmartTableViewCell: UITableViewCell {

    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func nib() -> UINib? {
        let bundle = Bundle(for: self)
        
        // The path check is to ensure that the file exists.
        // UINib doesn't verify the nib's existence.
        if bundle.path(forResource: self.nibName(), ofType: "nib") == nil {
            return nil;
        }
        
        return UINib(nibName: self.nibName(), bundle: bundle)
    }
    
    class func nibName() -> String {
        return self.cellIdentifier()
    }
    
    class func cellIdentifier() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    class func cellStyle() -> UITableViewCellStyle {
        return UITableViewCellStyle.default
    }

    class func cell(_ tableView: UITableView, reuseID: String? = nil, nib: UINib? = nil) -> Self {
        return createCell(tableView, reuseID: reuseID, nib: nib)
    }
    
    fileprivate class func createCell<C>(_ tableView: UITableView, reuseID: String? = nil, nib: UINib? = nil) -> C where C: SmartTableViewCell {
        
        let identifier = reuseID ?? self.cellIdentifier()
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? C {
            return cell
        }
        
        if let nib = self.nib() {
            if let cell = nib.instantiate(withOwner: nil, options: nil).first as? C {
                return cell
            }
        }
        
        return C(style: self.cellStyle(), reuseIdentifier: identifier)
    }
}
