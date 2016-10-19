//
//  YSDriveViewModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/22/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSDriveViewModel: YSDriveViewModelProtocol
{
    internal var isLoggedIn: Bool
    {
       return (model?.isLoggedIn)!
    }
    
    internal var isItemsPresent: Bool
    {
        return items != nil
    }
    
    internal var error : YSError = YSError()
    {
        didSet
        {
            if !error.isEmpty()
            {
                viewDelegate?.errorDidChange(viewModel: self, error: error)
            }
        }
    }

    weak var viewDelegate: YSDriveViewModelViewDelegate?
    var coordinatorDelegate: YSDriveViewModelCoordinatorDelegate?
    
    fileprivate var items: [YSDriveItem]?
    {
        didSet
        {
            viewDelegate?.itemsDidChange(viewModel: self)
        }
    }
    
    var model: YSDriveModel?
    {
        didSet
        {
            items = nil
            model?.items
            { (items, error) in
                self.items = items
                self.error = error!
            }
        }
    }
    
    var numberOfItems: Int
    {
        if let items = items
        {
            return items.count
        }
        return 0
    }
    
    func itemAtIndex(_ index: Int) -> YSDriveItem?
    {
        if let items = items , items.count > index
        {
            return items[index]
        }
        return nil
    }
    
    func useItemAtIndex(_ index: Int)
    {
        if let items = items, let coordinatorDelegate = coordinatorDelegate, index < items.count
        {
            coordinatorDelegate.driveViewModelDidSelectData(self, data: items[index])
        }
    }
    
    func loginToDrive()
    {
        coordinatorDelegate?.driveViewModelDidRequestedLogin()
    }
    
    func removeDownloads()
    {
        items?.removeAll()
        viewDelegate?.itemsDidChange(viewModel: self)
    }
}
