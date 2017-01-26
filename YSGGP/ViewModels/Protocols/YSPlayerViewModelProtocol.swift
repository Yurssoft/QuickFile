//
//  YSPlayerViewModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSPlayerDelegate: class
{
    func currentFilePlayingDidChange(viewModel: YSPlayerViewModelProtocol?)
}

protocol YSPlayerViewModelViewDelegate: class
{
    func playerDidChange(viewModel: YSPlayerViewModelProtocol)
    func timeDidChange(viewModel: YSPlayerViewModelProtocol)
    func errorDidChange(viewModel: YSPlayerViewModelProtocol, error: YSErrorProtocol)
}

protocol YSPlayerViewModelCoordinatorDelegate: class
{
    func showPlayer()
}

protocol YSPlayerViewModelProtocol
{
    var playerDelegate: YSPlayerDelegate? { get set }
    var model: YSPlaylistAndPlayerModelProtocol? { get set }
    var viewDelegate: YSPlayerViewModelViewDelegate? { get set }
    var coordinatorDelegate: YSPlayerViewModelCoordinatorDelegate? { get set }
    var error : YSErrorProtocol { get }
    var isPlaying : Bool { get }
    var currentFile: YSDriveFileProtocol? { get }
    var fileDuration: TimeInterval { get }
    var fileCurrentTime: TimeInterval { get }
    var playerVolume: Float { get }
    
    func togglePlayPause()
    func play(file: YSDriveFileProtocol?)
    func pause()
    func next()
    func previous()
    func set(volume: Float)
    func seek(to time:Double)
    func seekFloat(to time:Float)
}
