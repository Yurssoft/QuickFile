//
//  YSError.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSError : YSErrorProtocol
{
    let errorType : YSErrorType
    let message : String
    
    init(errorType : YSErrorType, message : String)
    {
        self.errorType = errorType
        self.message = message
    }
    
    init()
    {
        self.errorType = YSErrorType.none
        self.message = ""
    }
}
