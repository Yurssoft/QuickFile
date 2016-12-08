//
//  YSPlaylistCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/7/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import UIKit

protocol YSPlaylistCoordinatorDelegate: class
{
    func playlistCoordinatorDidRequestToPlayFile(driveVC: YSDriveCoordinator, file: YSDriveFileProtocol)
}

class YSPlaylistCoordinator: YSCoordinatorProtocol
{
    fileprivate var playlistViewController: YSPlaylistViewController
    weak var delegate : YSPlaylistCoordinatorDelegate?
    
    init(playlistViewController: YSPlaylistViewController)
    {
        self.playlistViewController = playlistViewController
    }
    
    func start()
    {
        let viewModel =  YSPlaylistViewModel()
        playlistViewController.viewModel = viewModel
        viewModel.model = YSPlaylistModel()
    }
}
