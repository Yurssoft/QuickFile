//
//  YSDriveSearchCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 2/17/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SwiftMessages

class YSDriveSearchCoordinator: YSCoordinatorProtocol {
    fileprivate var searchNavigationController: UINavigationController?
    fileprivate var driveCoordinator = YSDriveTopCoordinator()
    fileprivate var storyboard: UIStoryboard?
    fileprivate weak var searchViewModel: YSDriveSearchViewModel?

    func start(navigationController: UINavigationController?, storyboard: UIStoryboard?) {
        self.storyboard = storyboard
        guard let searchControllerNavigation = storyboard?.instantiateViewController(withIdentifier: YSConstants.kDriveSearchNavigation) as? UINavigationController,
        let searchController = searchControllerNavigation.viewControllers.first as? YSDriveSearchController else { return }

        let viewModel = YSDriveSearchViewModel()
        viewModel.model = YSDriveSearchModel()
        YSAppDelegate.appDelegate().downloadsDelegate = viewModel
        viewModel.coordinatorDelegate = self
        searchController.viewModel = viewModel
        searchViewModel = viewModel
        navigationController?.present(searchControllerNavigation, animated: true)
        searchNavigationController = searchControllerNavigation
    }
}

extension YSDriveSearchCoordinator: YSDriveSearchViewModelCoordinatorDelegate {
    func searchViewModelDidSelectFile(_ viewModel: YSDriveSearchViewModelProtocol, file: YSDriveFileProtocol) {
        if file.isAudio {
            if let url = file.localFilePath(), file.localFileExists() {
                let player = AVPlayer(url: url as URL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                searchNavigationController?.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            } else {
                let error = YSError(errorType: YSErrorType.couldNotDownloadFile, messageType: Theme.warning, title: "Could not play song", message: "No local copy", buttonTitle: "Download")
                viewModel.viewDelegate?.downloadErrorDidChange(viewModel: viewModel, error: error, id: file.id)
            }
        } else {
            guard let driveTopVC = storyboard?.instantiateViewController(withIdentifier: YSDriveTopViewController.nameOfClass) as? YSDriveTopViewController else { return }
            searchNavigationController?.pushViewController(driveTopVC, animated: true)
            var ysFolder = YSFolder()
            ysFolder.folderID = file.id
            ysFolder.folderName = file.name
            driveCoordinator.folders = [ysFolder]
            driveCoordinator.start(driveTopVC: driveTopVC, shouldShowSearch: false)
        }
    }

    func searchViewModelDidFinish() {
        YSAppDelegate.appDelegate().searchCoordinator = nil
        guard let coordinators = YSAppDelegate.appDelegate().driveTopCoordinator?.driveCoordinators else { return }
        coordinators[coordinators.index(coordinators.startIndex, offsetBy: coordinators.count - 1)].updateDownloadDelegate()
    }

    func subscribeToDownloadingProgress() {
        YSAppDelegate.appDelegate().downloadsDelegate = searchViewModel
    }
}
