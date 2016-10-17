//
//  YSSettingsModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/17/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSSettingsModel
{
    var isLoggedIn : Bool
    {
        return YSDriveManager.sharedInstance.isLoggedIn
    }
    
    func logOut() throws
    {
        do
        {
            try YSDriveManager.sharedInstance.logOut()
        }
        catch
        {
            throw error
        }
    }
}
