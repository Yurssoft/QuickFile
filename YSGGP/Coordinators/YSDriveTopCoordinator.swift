//
//  YSDriveTopCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/25/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSDriveTopCoordinator: YSCoordinatorProtocol
{
    fileprivate var driveCoordinators : [YSDriveCoordinator] = []
    fileprivate var navigationController: UINavigationController?
    fileprivate var folderID : String = ""
    fileprivate var storyboard: UIStoryboard?
    
    func start() { }
    
    func start(driveTopVC: YSDriveTopViewController)
    {
        driveTopVC.driveVCReadyDelegate = self
        storyboard = driveTopVC.storyboard
    }
    
    func driveCoordinatorDidRequestedLogin()
    {
        print(navigationController?.tabBarController)
        //navigate to settings
    }
}

extension YSDriveTopCoordinator : YSDriveViewControllerDidFinishedLoading
{
    func driveViewControllerDidLoaded(driveVC: YSDriveViewController, navigationController: UINavigationController)
    {
        self.navigationController = navigationController
        let driveCoordinator = YSDriveCoordinator(driveViewController: driveVC, folderID: folderID)
        driveCoordinator.start()
        driveCoordinator.delegate = self
        driveCoordinators.append(driveCoordinator)
    }
}

extension YSDriveTopCoordinator : YSDriveCoordinatorDelegate
{
    func driveCoordinatorDidFinish(driveVC: YSDriveCoordinator, error: YSErrorProtocol?)
    {
        if let index = driveCoordinators.index(of: driveVC)
        {
            driveCoordinators.remove(at: index)
            var viewControllers : [UIViewController] = []
            for i in 0...(navigationController?.childViewControllers.count)! - 1
            {
                viewControllers.append((navigationController?.childViewControllers[i])!)
            }
            navigationController?.setViewControllers(viewControllers, animated: false)
            if let lastCoordinator = driveCoordinators.last
            {
                folderID = lastCoordinator.folderID
            }
            else
            {
                folderID = ""
            }
        }
    }
    
    func driveCoordinatorDidSelectFile(_ viewModel: YSDriveViewModelProtocol, file: YSDriveFileProtocol)
    {
        if (file.isAudio)
        {
            print("open player")
        }
        else
        {
            folderID = file.fileDriveIdentifier
            let driveTopVC = storyboard?.instantiateViewController(withIdentifier: YSDriveTopViewController.nameOfClass) as! YSDriveTopViewController
            driveTopVC.driveVCReadyDelegate = self
            navigationController?.pushViewController(driveTopVC, animated: true)
        }
    }
}
