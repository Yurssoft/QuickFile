//
//  YSAppCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

protocol YSDriveCoordinatorDelegate: class
{
    func driveCoordinatorDidFinish(listCoordinator: YSDriveCoordinator)
}

class YSDriveCoordinator: YSCoordinator
{
    init(driveViewController: YSDriveViewController, navigationController: UINavigationController)
    {
        self.driveViewController = driveViewController
        self.navigationController = navigationController
    }
    
    weak var delegate: YSDriveCoordinatorDelegate?
    var driveViewController: YSDriveViewController?
    var driveModel: YSDriveModel?
    var navigationController: UINavigationController?
    
    func start()
    {
        let viewModel =  YSDriveViewModel()
        viewModel.model = YSDriveModel()
        viewModel.coordinatorDelegate = self
        driveModel = viewModel.model
        driveViewController?.viewModel = viewModel
    }
}

extension YSDriveCoordinator: YSDriveViewModelCoordinatorDelegate
{
    func driveViewModelDidSelectData(_ viewModel: YSDriveViewModel, data: YSDriveItem)
    {
        
    }

    func driveViewModelDidRequestedLogin()
    {
        if let authController = driveModel?.createAuthController({ 
            [weak self] in self?.navigationController?.dismiss(animated: true, completion: nil)
            self?.start()
        })
        {
            navigationController?.present(authController, animated: true, completion: nil)
        }
    }
}
