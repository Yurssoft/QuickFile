//
//  YSPlaylistCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/7/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import SwiftMessages

class YSPlaylistCoordinator: YSCoordinatorProtocol {
    func start(playlistViewController: YSPlaylistViewController) {
        let viewModel =  YSPlaylistViewModel()
        playlistViewController.viewModel = viewModel
        YSAppDelegate.appDelegate().playerCoordinator.viewModel.playerDelegate = viewModel
        YSAppDelegate.appDelegate().playlistDelegate = viewModel
        viewModel.model = YSPlaylistAndPlayerModel()
        viewModel.coordinatorDelegate = self
    }
}

extension YSPlaylistCoordinator: YSPlaylistViewModelCoordinatorDelegate {
    func playlistViewModelDidSelectFile(_ viewModel: YSPlaylistViewModelProtocol, file: YSDriveFileProtocol) {
        YSAppDelegate.appDelegate().playerCoordinator.play(file: file)
    }
}
