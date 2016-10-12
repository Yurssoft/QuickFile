//
//  YSDriveItemCell.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    
    var item: YSDriveItem?
    {
        didSet
        {
            fileNameLabel?.text = item?.fileName
            fileInfoLabel?.text = item?.fileInfo
            fileImageView?.image = UIImage(named: (item?.isAudio)! ? "song" : "folder")
        }
    }
    
}
