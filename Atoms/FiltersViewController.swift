//
//  FiltersViewController.swift
//  Atoms
//
//  Created by Robert Brown on 8/6/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

class FiltersViewController: UITableViewController {

    private(set) var filters = Set<String>()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if let title = cell?.textLabel?.text {
            let filterName = "CI" + title.stringByReplacingOccurrencesOfString(" ", withString: "")
            if filters.contains(filterName) {
                filters.remove(filterName)
                cell?.accessoryType = .None
            }
            else {
                filters.insert(filterName)
                cell?.accessoryType = .Checkmark
            }
        }
    }
}
