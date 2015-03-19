//
//  SmartCollectionViewCell.swift
//  Atoms
//
//  Created by Robert Brown on 3/10/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

class SmartCollectionViewCell: UICollectionViewCell {
    
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
    
    class func cell(collectionView: UICollectionView, indexPath: NSIndexPath, reuseID: String? = nil, nib: UINib? = nil) -> Self {
        return createCell(collectionView, indexPath: indexPath, reuseID: reuseID, nib: nib)
    }
    
    private class func createCell<C where C: SmartCollectionViewCell>(collectionView: UICollectionView, indexPath: NSIndexPath, reuseID: String? = nil, nib: UINib? = nil) -> C {
        
        let identifier = reuseID ?? self.cellIdentifier()
        
        if let nib = self.nib() {
            collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
        }
        
        return collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! C
    }
}
