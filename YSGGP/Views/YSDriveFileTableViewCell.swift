//
//  YSDriveFileTableViewCell.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import MRProgress

protocol YSDriveFileTableViewCellDelegate : class
{
    func downloadButtonPressed(_ file: YSDriveFileProtocol)
}

class YSDriveFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var progressView: MRCircularProgressView!
    @IBOutlet weak var downloadButton: UIButton!
    weak var delegate: YSDriveFileTableViewCellDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        downloadButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func configure(_ file : YSDriveFileProtocol?,_ delegate : YSDriveFileTableViewCellDelegate, _ download : YSDownloadProtocol?)
    {
        self.file = file
        self.delegate = delegate
        self.download = download
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton)
    {
        delegate?.downloadButtonPressed(file!)
    }
    
    var file: YSDriveFileProtocol?
    {
        didSet
        {
            if let file = file
            {
                progressView.mayStop = true
                fileNameLabel?.text = file.fileName
                fileInfoLabel?.text = file.fileSize
                fileImageView?.image = UIImage(named: file.isAudio ? "song" : "folder")
                downloadButton.isHidden = file.isFileOnDisk
            }
        }
    }
    
    var download : YSDownloadProtocol?
    {
        didSet
        {
            if let download = download
            {
                progressView.isHidden = !download.isDownloading
                downloadButton.isHidden = download.isDownloading
                progressView.setProgress(download.progress, animated: true)
            }
            else
            {
                progressView.isHidden = true
            }
        }
    }
}
