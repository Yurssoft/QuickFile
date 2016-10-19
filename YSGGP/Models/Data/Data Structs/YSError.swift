//
//  YSError.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

struct YSError : YSErrorProtocol
{
    let errorType : YSErrorType
    let messageType: Theme
    let title: String
    let message : String
    let buttonTitle : String
    
    init(errorType : YSErrorType, messageType: Theme, title: String, message : String, buttonTitle : String)
    {
        self.errorType = errorType
        self.messageType = messageType
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
    }
    
    init()
    {
        self.errorType = YSErrorType.none
        self.messageType = Theme.info
        self.title = ""
        self.message = ""
        self.buttonTitle = ""
    }
    
    func isEmpty() -> Bool
    {
        if
        self.errorType == YSErrorType.none &&
        self.messageType == Theme.info &&
        self.title == "" &&
        self.message == "" &&
        self.buttonTitle == ""
        {
            return true
        }
        return false
    }
}
