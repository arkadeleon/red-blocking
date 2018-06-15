//
//  PropertyListBasedTableViewCell.swift
//  MaChérie
//
//  Created by Leon Li on 2018/6/13.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

class PropertyListBasedTableViewCell: UITableViewCell {
    @IBOutlet var leftImageView: UIImageView!
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    
    @IBOutlet var spacingBetweenLeftImageViewAndLeftLabel: NSLayoutConstraint!
    @IBOutlet var spacingBetweenLeftLabelAndRightLabel: NSLayoutConstraint!
    
    func canBeSelected() -> Bool {
        return true
    }
}
