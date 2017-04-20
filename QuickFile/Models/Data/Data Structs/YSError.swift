//
//  YSError.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/19/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages
import SwiftyBeaver

struct YSError : YSErrorProtocol
{
    var errorType : YSErrorType
    var messageType: Theme
    var title: String
    var message : String
    let buttonTitle : String
    let debugInfo : String
    
    init(errorType : YSErrorType, messageType: Theme, title: String, message : String, buttonTitle : String)
    {
        self.errorType = errorType
        self.messageType = messageType
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.debugInfo = ""
    }
    
    init(errorType : YSErrorType, messageType: Theme, title: String, message : String, buttonTitle : String, debugInfo : String)
    {
        self.errorType = errorType
        self.messageType = messageType
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.debugInfo = debugInfo
        if !debugInfo.isEmpty
        {
            let log = SwiftyBeaver.self
            log.info("debug info : \(debugInfo)")
        }
    }
    
    init()
    {
        self.errorType = YSErrorType.none
        self.messageType = Theme.info
        self.title = ""
        self.message = ""
        self.buttonTitle = ""
        self.debugInfo = ""
    }
    
    mutating func update(errorType : YSErrorType, messageType: Theme, title: String, message : String)
    {
        self.errorType = errorType
        self.messageType = messageType
        self.title = title
        self.message = message
    }
    
    func isEmpty() -> Bool
    {
        if
        self.errorType == YSErrorType.none &&
        self.messageType == Theme.info &&
        self.title == "" &&
        self.message == "" &&
        self.buttonTitle == "" &&
        self.debugInfo == ""
        {
            return true
        }
        return false
    }
}
