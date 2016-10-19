//
//  YSDriveModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSDriveModelProtocol
{
    var isLoggedIn : Bool {get}
    
    func items(_ completionHandler: (([YSDriveItem], YSError?) -> Swift.Void)?)
}
