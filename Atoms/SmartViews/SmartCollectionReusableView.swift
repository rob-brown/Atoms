//
//  SmartCollectionReusableView.swift
//  Atoms
//
//  Created by Robert Brown on 3/10/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

class SmartCollectionReusableView: UICollectionReusableView {
    
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
    
    class func cell(collectionView: UICollectionView, indexPath: NSIndexPath, kind: String, reuseID: String? = nil, nib: UINib? = nil) -> Self {
        return createView(collectionView, indexPath: indexPath, kind: kind, nib: nib)
    }
    
    private class func createView<C where C: SmartCollectionReusableView>(collectionView: UICollectionView, indexPath: NSIndexPath, kind: String, reuseID: String? = nil, nib: UINib? = nil) -> C {
        
        let identifier = reuseID ?? self.cellIdentifier()
        
        if let nib = self.nib() {
            collectionView.registerNib(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        }
        
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: identifier, forIndexPath: indexPath) as! C
    }
}
