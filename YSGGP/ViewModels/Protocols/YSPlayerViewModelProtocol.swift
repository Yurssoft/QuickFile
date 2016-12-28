//
//  YSPlayerViewModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSPlayerViewModelViewDelegate: class
{
    func playerDidChange(viewModel: YSPlayerViewModelProtocol)
    func filesDidChange(viewModel: YSPlayerViewModelProtocol)
    func errorDidChange(viewModel: YSPlayerViewModelProtocol, error: YSErrorProtocol)
}

protocol YSPlayerViewModelProtocol
{
    var model: YSPlayerModelProtocol? { get set }
    var viewDelegate: YSPlayerViewModelViewDelegate? { get set }
    var error : YSErrorProtocol { get }
    var isPlaying : Bool { get }
    
    func playPause()
    func next()
    func previous()
    func currentFile() -> YSDriveFileProtocol
}
