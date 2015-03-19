//
//  WordCell.swift
//  Atoms
//
//  Created by Robert Brown on 3/18/15.
//  Copyright (c) 2015 Robert Brown. All rights reserved.
//

import UIKit

class WordCell: SmartTableViewCell {

    @IBOutlet weak var wordLabel: UILabel!
    
    class func cell(tableView: UITableView, word: String) -> Self {
        let cell = self.cell(tableView)
        cell.wordLabel.text = word
        return cell
    }
}
