//
//  YSPlaylistViewModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/6/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSPlaylistViewModelViewDelegate: class
{
    func filesDidChange(viewModel: YSDriveViewModelProtocol)
    func errorDidChange(viewModel: YSDriveViewModelProtocol, error: YSErrorProtocol)
}

protocol YSPlaylistViewModelCoordinatorDelegate: class
{
    func playlistViewModelDidSelectFile(_ viewModel: YSDriveViewModelProtocol, file: YSDriveFileProtocol)
}

protocol YSPlaylistViewModelProtocol
{
    var model: YSPlaylistModelProtocol? { get set }
    var viewDelegate: YSPlaylistViewModelViewDelegate? { get set }
    var coordinatorDelegate: YSPlaylistViewModelCoordinatorDelegate? { get set}
    var numberOfFiles: Int { get }
    var numberOfFolders: Int { get }
    var error : YSErrorProtocol { get }
    
    func file(at index: Int) -> YSDriveFileProtocol?
    func folder(at index: Int) -> YSDriveFileProtocol?
    func useFile(at index: Int)
    func removeDownloads()
    func getFiles(completion: @escaping CompletionHandler)
    func indexOf(_ file : YSDriveFileProtocol) -> Int
}
