//
//  YSPlayerViewModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

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
    
    deinit
    {
        player.pause()
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
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.nextTrackCommand.isEnabled = true
            //commandCenter.nextTrackCommand.addTarget(self, action:#selector(nextTrackCommandSelector()))
            player = AVQueuePlayer(items: audioItems)
            viewDelegate?.playerDidChange(viewModel: self)
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
    
    var isPlaying : Bool = false
    {
        didSet
        {
            viewDelegate?.playerDidChange(viewModel: self)
        }
    }
    
    func playPause()
    {
        player.rate == 0 ? player.play() : player.pause()
        isPlaying = player.rate != 0
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
        if let itemURL = currentItemUrl()
        {
            let filesOfURL = files.filter { $0.localFilePath() == itemURL }
            return filesOfURL.first!
        }
        return YSDriveFile()
    }
    
    func currentItemUrl() -> URL? {
        let asset = player.currentItem?.asset
        if asset == nil
        {
            return nil
        }
        if let urlAsset = asset as? AVURLAsset
        {
            return urlAsset.url
        }
        return nil
    }
}
