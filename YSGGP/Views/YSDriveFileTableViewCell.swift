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
    func stopDownloadButtonPressed(_ file: YSDriveFileProtocol)
}

class YSDriveFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    weak var delegate: YSDriveFileTableViewCellDelegate?
    
    @IBOutlet weak var downloadButton: PKDownloadButton!
    
    func configure(_ file : YSDriveFileProtocol?,_ delegate : YSDriveFileTableViewCellDelegate?, _ download : YSDownloadProtocol?)
    {
        self.file = file
        self.delegate = delegate
        if let file = file
        {
            fileNameLabel?.text = file.fileName
            fileInfoLabel?.text = file.fileSize
            fileImageView?.image = UIImage(named: file.isAudio ? "song" : "folder")
            if file.isAudio
            {
                if file.isFileOnDisk
                {
                    downloadButton.isHidden = file.isFileOnDisk
                    return
                }
                if let download = download
                {
                    downloadButton.isHidden = false
                    switch download.downloadStatus
                    {
                    case .downloading(let progress):
                        downloadButton.state = .downloading
                        downloadButton.stopDownloadButton.progress = CGFloat(progress)
                        break
                    case .pending:
                        downloadButton.state = .pending
                        downloadButton.pendingView.startSpin()
                        break
                    }
                }
                else
                {
                    downloadButton.state = .startDownload
                    downloadButton.isHidden = false
                    downloadButton.startDownloadButton.cleanDefaultAppearance()
                    downloadButton.startDownloadButton.setImage(UIImage.init(named: "cloud_download"), for: .normal)
                }
            }
            else
            {
                downloadButton.isHidden = true
            }
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
            downloadButton.state = .pending
            downloadButton.pendingView.startSpin()
            delegate?.downloadButtonPressed(file!)
            break
        case .pending, .downloading:
            downloadButton.state = .startDownload
            delegate?.stopDownloadButtonPressed(file!)
            break
        case .downloaded:
            downloadButton.isHidden = true
            break
        }
    }
}
