//
//  WordCollectionCell.swift
//  Atoms
//
//  Created by Robert Brown on 3/18/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

class WordCollectionCell: SmartCollectionViewCell {

    @IBOutlet weak var wordLabel: UILabel!
    
    class func cell(collectionView: UICollectionView, indexPath: NSIndexPath, word: String) -> Self {
        let cell = self.cell(collectionView, indexPath: indexPath)
        cell.wordLabel.text = word
        return cell
    }
}
