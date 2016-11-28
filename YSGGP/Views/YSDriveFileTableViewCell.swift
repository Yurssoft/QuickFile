//
//  YSDriveFileTableViewCell.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import DownloadButton

protocol YSDriveFileTableViewCellDelegate : class
{
    func downloadButtonPressed(_ file: YSDriveFileProtocol)
}

class YSDriveFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    weak var delegate: YSDriveFileTableViewCellDelegate?
    
    @IBOutlet weak var downloadButton: PKDownloadButton!
    
    func configure(_ file : YSDriveFileProtocol?,_ delegate : YSDriveFileTableViewCellDelegate, _ download : YSDownloadProtocol?)
    {
        if let file = file
        {
            fileNameLabel?.text = file.fileName
            fileInfoLabel?.text = file.fileSize
            if file.isAudio
            {
                if let download = download
                {
                    downloadButton.stopDownloadButton.progress = CGFloat(download.progress)
                    downloadButton.isHidden = download.isDownloading
                }
                else
                {
                    downloadButton.startDownloadButton.cleanDefaultAppearance()
                    downloadButton.startDownloadButton.setImage(UIImage.init(named: "cloud_download"), for: .normal)
                }
                fileImageView?.image = UIImage(named:"song")
                downloadButton.isHidden = file.isFileOnDisk
            }
            else
            {
                fileImageView?.image = UIImage(named:"folder")
                downloadButton.isHidden = true
            }
        }
        self.file = file
        self.delegate = delegate
    }
    
    func update(_ file : YSDriveFileProtocol?, _ download : YSDownloadProtocol?)
    {
        if let download = download
        {
            downloadButton.stopDownloadButton.progress = CGFloat(download.progress)
            downloadButton.isHidden = download.isDownloading
        }
        else
        {
            downloadButton.startDownloadButton.cleanDefaultAppearance()
            downloadButton.startDownloadButton.setImage(UIImage.init(named: "cloud_download"), for: .normal)
        }
        if let file = file
        {
            downloadButton.isHidden = file.isFileOnDisk
        }
    }
    
    var file: YSDriveFileProtocol?
}

extension YSDriveFileTableViewCell: PKDownloadButtonDelegate
{
    func downloadButtonTapped(_ downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState)
    {
        switch (state)
        {
        case .startDownload:
            downloadButton.state = .downloading
            delegate?.downloadButtonPressed(file!)
            break
        case .pending:
            downloadButton.state = .startDownload
            break
        case .downloading:
            downloadButton.state = .startDownload
            break
        case .downloaded:
            downloadButton.state = .startDownload
            break
        }
    }
}
