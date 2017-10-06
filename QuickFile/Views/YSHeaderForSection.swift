//
//  YSHeaderForSection.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/8/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import UIKit

class YSHeaderForSection: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    func configure(title: String?) {
        if let title = title {
            titleLabel.text = title
        } else {
            titleLabel.text = ""
        }
        contentView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    }
}
