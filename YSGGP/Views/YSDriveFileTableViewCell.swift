//
//  YSDriveFileTableViewCell.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import FFCircularProgressView

protocol YSDriveFileTableViewCellDelegate : class
{
    func downloadButtonPressed(_ file: YSDriveFileProtocol)
}

class YSDriveFileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var progressView: UIView!
    var ffprogressView: FFCircularProgressView!
    @IBOutlet weak var downloadButton: UIButton!
    weak var delegate: YSDriveFileTableViewCellDelegate?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        downloadButton.imageView?.contentMode = .scaleAspectFit
    }
    
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
                    if progressView.subviews.first == nil
                    {
                        progressView.isHidden = false
                        ffprogressView = FFCircularProgressView.init(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                        progressView.addSubview(ffprogressView)
                    }
                    ffprogressView.progress = CGFloat(download.progress)
                    
                    progressView.isHidden = !download.isDownloading
                    downloadButton.isHidden = download.isDownloading
                }
                else
                {
                    progressView.subviews.first?.removeFromSuperview()
                    progressView.isHidden = true
                }
                fileImageView?.image = UIImage(named:"song")
                downloadButton.isHidden = file.isFileOnDisk
            }
            else
            {
                progressView.subviews.first?.removeFromSuperview()
                progressView.isHidden = true
                fileImageView?.image = UIImage(named:"folder")
                downloadButton.isHidden = true
            }
        }
        self.file = file
        self.delegate = delegate
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        progressView.isHidden = true
        progressView.subviews.first?.removeFromSuperview()
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton)
    {
        delegate?.downloadButtonPressed(file!)
    }
    
    var file: YSDriveFileProtocol?
}
