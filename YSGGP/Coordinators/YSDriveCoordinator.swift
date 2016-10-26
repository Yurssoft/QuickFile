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
    func driveCoordinatorDidFinish(driveVC: YSDriveCoordinator, error: YSErrorProtocol?)
    func driveCoordinatorDidSelectFile(_ viewModel: YSDriveViewModel, file: YSDriveFileProtocol)
    func driveCoordinatorDidRequestedLogin()
}

class YSDriveCoordinator: NSObject, YSCoordinatorProtocol
{
    fileprivate let driveViewController: YSDriveViewController
    weak var delegate : YSDriveCoordinatorDelegate?
    var folderID : String = ""
    
    init(driveViewController: YSDriveViewController, folderID: String)
    {
        self.driveViewController = driveViewController
        self.folderID = folderID
    }
    
    func start()
    {
        let viewModel = YSDriveViewModel()
        driveViewController.viewModel = viewModel
        viewModel.model = YSDriveModel(folderID: folderID)
        viewModel.coordinatorDelegate = self
    }
    
    fileprivate func start(folderID: String,error: YSError?)
    {
        let viewModel =  YSDriveViewModel()
        driveViewController.viewModel = viewModel
        viewModel.model = YSDriveModel(folderID: folderID)
        viewModel.coordinatorDelegate = self
        if error == nil
        {
            return
        }
        viewModel.viewDelegate?.errorDidChange(viewModel: viewModel, error: error!)
    }
}

extension YSDriveCoordinator: YSDriveViewModelCoordinatorDelegate
{
    func driveViewModelDidSelectFile(_ viewModel: YSDriveViewModel, file: YSDriveFileProtocol)
    {
        delegate?.driveCoordinatorDidSelectFile(viewModel, file: file)
    }

    func driveViewModelDidRequestedLogin()
    {
        delegate?.driveCoordinatorDidRequestedLogin()
    }
    
    func driveViewModelDidFinish()
    {
        delegate?.driveCoordinatorDidFinish(driveVC: self, error: nil)
    }
}
