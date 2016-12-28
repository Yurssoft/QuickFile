//
//  YSPlayerModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

typealias YSPlayerCompletionHandler = ([YSDriveFileProtocol], YSErrorProtocol?) -> Swift.Void

protocol YSPlayerModelProtocol
{
    func allFiles(_ completionHandler: @escaping YSPlayerCompletionHandler)
}
