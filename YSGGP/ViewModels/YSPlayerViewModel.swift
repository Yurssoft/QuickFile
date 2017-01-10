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

class YSPlayerViewModel: NSObject, YSPlayerViewModelProtocol, AVAudioPlayerDelegate
{
    let commandCenter = MPRemoteCommandCenter.shared()
    
    var timer : Timer?
    
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
        player?.pause()
        timer?.invalidate()
    }
    
    weak var viewDelegate: YSPlayerViewModelViewDelegate?
    weak var coordinatorDelegate: YSPlayerViewModelCoordinatorDelegate?
    
    var files : [YSDriveFileProtocol] = []
    {
        didSet
        {
            if currentFile == nil
            {
                currentFile = files.first
            }
            if files.count > 0
            {
                coordinatorDelegate?.showPlayer()
            }
            viewDelegate?.playerDidChange(viewModel: self)
        }
    }
    
    var model: YSPlayerModelProtocol?
    {
        didSet
        {
            timer = Timer.every(1.seconds)
            { [weak self] in
                guard let sself = self else { return }
                sself.viewDelegate?.timeDidChange(viewModel: sself)
                sself.updateNowPlayingInfoElapsedTime()
            }
            
            commandCenter.playCommand.addTarget (handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
                guard let sself = self else { return .commandFailed }
                sself.play()
                return .success
            })
            
            commandCenter.pauseCommand.addTarget (handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
                guard let sself = self else { return .commandFailed }
                sself.pause()
                return .success
            })
            
            commandCenter.nextTrackCommand.addTarget (handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
                guard let sself = self else { return .commandFailed }
                sself.next()
                return .success
            })
            
            commandCenter.previousTrackCommand.addTarget (handler: { [weak self] event -> MPRemoteCommandHandlerStatus in
                guard let sself = self else { return .commandFailed }
                sself.previous()
                return .success
            })
            model?.allFiles()
            { (files, error) in
                self.currentFile = files.first
                self.files = files
                if let error = error
                {
                    self.error = error
                }
            }
        }
    }

    var player: AVAudioPlayer?
    
    var isPlaying : Bool
    {
        return player?.isPlaying ?? false
    }
    
    var currentFile: YSDriveFileProtocol?
    
    var nextFile: YSDriveFileProtocol?
    {
        guard let currentPlaybackFile = currentFile, files.count > 0 else { return nil }
        
        let nextItemIndex = files.index(where: {$0.fileDriveIdentifier == currentPlaybackFile.fileDriveIdentifier})! + 1
        if nextItemIndex >= files.count { return nil }
        
        return files[nextItemIndex]
    }
    
    var previousFile: YSDriveFileProtocol?
    {
        guard let currentPlaybackFile = currentFile, files.count > 0 else { return nil }
        
        let previousItemIndex = files.index(where: {$0.fileDriveIdentifier == currentPlaybackFile.fileDriveIdentifier})! - 1
        if previousItemIndex < 0 { return nil }
        
        return files[previousItemIndex]
    }
    
    var nowPlayingInfo: [String : AnyObject]?
    
    var fileDuration: TimeInterval
    {
        return player?.duration ?? 0
    }
    
    var fileCurrentTime: TimeInterval
    {
        return player?.currentTime ?? 0
    }
    
    func togglePlayPause()
    {
        isPlaying ? self.pause() : self.play()
    }
    
    func play(file: YSDriveFileProtocol?)
    {
        var file = file
        if file == nil
        {
            file = files.first
        }
        guard let fileUrl = file?.localFilePath(), let audioPlayer = try? AVAudioPlayer(contentsOf: fileUrl) else
        {
            endPlayback()
            return
        }
        coordinatorDelegate?.showPlayer()
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        player = audioPlayer
        currentFile = file
        play()
    }
    
    func play()
    {
        guard let player = player else
        {
            play(file: currentFile)
            return
        }
        player.play()
        viewDelegate?.playerDidChange(viewModel: self)
        updateNowPlayingInfoForCurrentPlaybackItem()
    }
    
    func pause()
    {
        player?.pause()
        viewDelegate?.playerDidChange(viewModel: self)
        updateNowPlayingInfoForCurrentPlaybackItem()
    }
    
    func next()
    {
        guard let nextFile = nextFile  else {
            return
        }
        play(file: nextFile)
        viewDelegate?.playerDidChange(viewModel: self)
        updateNowPlayingInfoForCurrentPlaybackItem()
    }
    
    func previous()
    {
        guard let previousFile = previousFile  else {
            return
        }
        play(file: previousFile)
        viewDelegate?.playerDidChange(viewModel: self)
        updateNowPlayingInfoForCurrentPlaybackItem()
    }
    
    //MARK: - Now Playing Info
    
    func updateNowPlayingInfoForCurrentPlaybackItem()
    {
        guard let player = player, let currentPlaybackItem = currentFile else
        {
            let emptyPlayingInfo = [:] as [String : AnyObject]
            set(emptyPlayingInfo)
            return
        }
        
        var nowPlayingInfo = [MPMediaItemPropertyTitle: currentPlaybackItem.fileName,
                              MPMediaItemPropertyAlbumTitle: currentPlaybackItem.folder.folderName,
                              MPMediaItemPropertyPlaybackDuration: player.duration,
                              MPNowPlayingInfoPropertyPlaybackRate: NSNumber(value: 1.0 as Float),
                              MPNowPlayingInfoPropertyElapsedPlaybackTime: NSNumber(value: player.currentTime as Double) ] as [String : Any]
        
        if let image = UIImage(named: "song")
        {
            let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
                return image
            })
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        set(nowPlayingInfo as [String : AnyObject]?)
    }
    
    func updateNowPlayingInfoElapsedTime()
    {
        guard let player = player, var nowPlayingInfo = nowPlayingInfo else { return }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: player.currentTime as Double)
        
        set(nowPlayingInfo)
    }
    
    func set(_ nowPlayingInfo: [String: AnyObject]?)
    {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        self.nowPlayingInfo = nowPlayingInfo
    }
    
    //MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        nextFile == nil ? endPlayback() : next()
    }
    
    func endPlayback()
    {
        currentFile = nil
        updateNowPlayingInfoForCurrentPlaybackItem()
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer)
    {
    }
    
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int)
    {
        if AVAudioSessionInterruptionOptions(rawValue: UInt(flags)) == .shouldResume
        {
            play()
        }
    }
    
    func seek(to time:Float)
    {
        player?.currentTime = Double(time)
        viewDelegate?.timeDidChange(viewModel: self)
    }
}
