//
//  YSAppCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveCoordinator: YSCoordinatorProtocol
{
    fileprivate var driveViewController: YSDriveViewController?
    fileprivate var navigationController: UINavigationController?
    
//    init(<#parameters#>) {
//        <#statements#>
//    }
    
    func start()
    {
        let viewModel = YSDriveViewModel()
        driveViewController?.viewModel = viewModel
        viewModel.model = YSDriveModel(folderID: "")
        viewModel.coordinatorDelegate = self
    }
    
    fileprivate func start(folderID: String,error: YSError?)
    {
        let viewModel =  YSDriveViewModel()
        driveViewController?.viewModel = viewModel
        viewModel.model = YSDriveModel(folderID: folderID)
        viewModel.coordinatorDelegate = self
        if error == nil
        {
            return
        }
        viewModel.viewDelegate?.errorDidChange(viewModel: viewModel, error: error!)
    }
}

extension YSDriveCoordinator : YSDriveViewControllerDidFinishedLoading
{
    func driveViewControllerDidLoaded(driveVC: YSDriveViewController, navigationController: UINavigationController)
    {
        driveViewController = driveVC
        self.navigationController = navigationController
        start()
    }
}

extension YSDriveCoordinator : YSAuthenticationCoordinatorDelegate
{
    func showAuthentication()
    {
        let authenticationCoordinator = YSAuthenticationCoordinator(navigationController: navigationController!)
        authenticationCoordinator.delegate = self
        authenticationCoordinator.start()
    }
    
    func authenticationCoordinatorDidFinish(authenticationCoordinator: YSAuthenticationCoordinator, error: YSError?)
    {
        start(folderID:"", error: error)
    }
}

extension YSDriveCoordinator: YSDriveViewModelCoordinatorDelegate
{
    func driveViewModelDidSelectFile(_ viewModel: YSDriveViewModel, file: YSDriveFile)
    {
        if (file.isAudio)
        {
            print("open player")
        }
        else
        {
            let driveTopVC = driveViewController?.storyboard?.instantiateViewController(withIdentifier: YSDriveTopViewController.nameOfClass) as! YSDriveTopViewController
            driveTopVC.driveViewControllerDidLoadedHandler =
            {
                self.start(folderID: file.fileDriveIdentifier, error: nil)
            }
            navigationController?.pushViewController(driveTopVC, animated: true)
        }
    }

    func driveViewModelDidRequestedLogin()
    {
        showAuthentication()
    }
}
