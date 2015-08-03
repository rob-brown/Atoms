//
//  SmartTableViewCell.swift
//  Atoms
//
//  Created by Robert Brown on 3/10/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

class SmartTableViewCell: UITableViewCell {

    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func nib() -> UINib? {
        let bundle = NSBundle(forClass: self)
        
        // The path check is to ensure that the file exists.
        // UINib doesn't verify the nib's existence.
        if bundle.pathForResource(self.nibName(), ofType: "nib") == nil {
            return nil;
        }
        
        return UINib(nibName: self.nibName(), bundle: bundle)
    }
    
    class func nibName() -> String {
        return self.cellIdentifier()
    }
    
    class func cellIdentifier() -> String {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    class func cellStyle() -> UITableViewCellStyle {
        return UITableViewCellStyle.Default
    }

    class func cell(tableView: UITableView, reuseID: String? = nil, nib: UINib? = nil) -> Self {
        return createCell(tableView, reuseID: reuseID, nib: nib)
    }
    
    private class func createCell<C where C: SmartTableViewCell>(tableView: UITableView, reuseID: String? = nil, nib: UINib? = nil) -> C {
        
        let identifier = reuseID ?? self.cellIdentifier()
        
        if let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? C {
            return cell
        }
        
        if let nib = self.nib() {
            if let cell = nib.instantiateWithOwner(nil, options: nil).first as? C {
                return cell
            }
        }
        
        return C(style: self.cellStyle(), reuseIdentifier: identifier)
    }
}
