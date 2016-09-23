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
//    weak var coordinatorDelegate: ListViewModelCoordinatorDelegate?
    
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
    
//    var title: String
//    {
//        return "Drive"
//    }
    
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
    
//    func useItemAtIndex(_ index: Int)
//    {
//        if let items = items, let coordinatorDelegate = coordinatorDelegate  , index < items.count
//        {
//            coordinatorDelegate.listViewModelDidSelectData(self, data: items[index])
//        }
//    }
}
