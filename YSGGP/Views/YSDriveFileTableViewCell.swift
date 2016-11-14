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
        self.file = file
        self.delegate = delegate
        self.download = download
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton)
    {
        delegate?.downloadButtonPressed(file!)
    }
    
    override var isEditing: Bool
    {
        didSet
        {
            downloadButton.isHidden = isEditing
        }
    }
    
    var file: YSDriveFileProtocol?
    {
        didSet
        {
            if let file = file
            {
                ffprogressView = FFCircularProgressView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                progressView.addSubview(ffprogressView)
                ffprogressView.progress = CGFloat(0.5)
                fileNameLabel?.text = file.fileName
                fileInfoLabel?.text = file.fileSize
                fileImageView?.image = UIImage(named: file.isAudio ? "song" : "folder")
                downloadButton.isHidden = file.isFileOnDisk || !file.isAudio
            }
        }
    }
    
    var download : YSDownloadProtocol?
    {
        didSet
        {
//            if let download = download
//            {
//                progressView.isHidden = !download.isDownloading || !(file?.isAudio)!
//                downloadButton.isHidden = download.isDownloading || !(file?.isAudio)!
//                progressView.startSpinProgressBackgroundLayer()
//                progressView.progress = CGFloat(download.progress)
//            }
//            else
//            {
//                progressView.isHidden = true
//            }
        }
    }
}
