//
//  YSDriveFileTableViewCell.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    
    var file: YSDriveFile?
    {
        didSet
        {
            fileNameLabel?.text = file?.fileName
            fileInfoLabel?.text = file?.fileSize
            fileImageView?.image = UIImage(named: (file?.isAudio)! ? "song" : "folder")
        }
    }
    
}
