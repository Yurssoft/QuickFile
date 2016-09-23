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
    func items(_ completionhandler: @escaping (_ items: [YSDriveItem]) -> Void)
}
