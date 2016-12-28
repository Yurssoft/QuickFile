//
//  YSPlayerViewModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import AVFoundation

class YSPlayerViewModel: YSPlayerViewModelProtocol
{
    var error: YSErrorProtocol = YSError.init()
    {
        didSet
        {
            if !error.isEmpty()
            {
                viewDelegate?.errorDidChange(viewModel: self, error: error)
            }
        }
    }
    
    var viewDelegate: YSPlayerViewModelViewDelegate?
    
    var files : [YSDriveFileProtocol] = []
    {
        didSet
        {
            var audioItems: [AVPlayerItem] = []
            for file in files
            {
                let item = AVPlayerItem(url: file.localFilePath()!)
                audioItems.append(item)
            }
            player = AVQueuePlayer(items: audioItems)
        }
    }
    
    var model: YSPlayerModelProtocol?
    {
        didSet
        {
            model?.allFiles()
            { (files, error) in
                self.files = files
                if let error = error
                {
                    self.error = error
                }
            }
        }
    }

    var player: AVQueuePlayer = AVQueuePlayer(items: [])
    
    func playPause()
    {
        player.rate == 0 ? player.play() : player.pause()
    }
    
    func next()
    {
        player.advanceToNextItem()
    }
    
    func previous()
    {
        
    }
    
    func currentFile() -> YSDriveFileProtocol
    {
        let item = player.currentItem
        return YSDriveFile()
    }
    
}
