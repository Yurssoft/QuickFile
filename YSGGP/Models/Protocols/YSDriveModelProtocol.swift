//
//  YSDriveModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

typealias DriveCompletionHandler = ([YSDriveFile], YSError?) -> Swift.Void

protocol YSDriveModelProtocol
{
    var isLoggedIn : Bool {get}
    
    func getFiles(_ completionHandler: DriveCompletionHandler?)
}
