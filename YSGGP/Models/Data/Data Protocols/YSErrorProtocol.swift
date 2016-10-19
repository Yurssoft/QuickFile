//
//  YSErrorProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSErrorProtocol : Error
{
    var errorType : YSErrorType { get }
    var message : String { get }
}
