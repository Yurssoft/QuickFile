//
//  YSSettingsViewModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/17/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSSettingsViewModel : YSSettingsViewModelProtocol
{
    var isLoggedIn : Bool
    {
        return model!.isLoggedIn
    }

    fileprivate var error : YSErrorProtocol = YSError()
    {
        didSet
        {
            if !error.isEmpty()
            {
                viewDelegate?.errorDidChange(viewModel: self, error: error)
            }
        }
    }
    
    weak var viewDelegate: YSSettingsViewModelViewDelegate?
    var model : YSSettingsModel?
    
    func logOut()
    {
        do
        {
            try model?.logOut()
        }
        catch
        {
            viewDelegate?.errorDidChange(viewModel: self, error: error as! YSErrorProtocol)
        }
    }
}
