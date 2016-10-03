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
    weak var viewDelegate: YSDriveViewModelViewDelegate?
    weak var coordinatorDelegate: YSDriveViewModelCoordinatorDelegate?
    
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
            items = nil;
            model?.items({ (items) in
                self.items = items
            })
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
    
    func removeItems()
    {
        items?.removeAll()
        viewDelegate?.itemsDidChange(viewModel: self)
    }
}
