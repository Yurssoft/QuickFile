//
//  ReqresDefaultLogger.swift
//  QuickFile
//
//  Created by Yurii Boiko on 9/8/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Reqres

open class ReqresDefaultLogger: ReqresLogging {
    
    open var logLevel: LogLevel = .verbose
    
    open func logVerbose(_ message: String) {
        #if DEBUG
            LogDefault(.Network, .Info, message)
        #endif
    }
    
    open func logLight(_ message: String) {
        #if DEBUG
            LogDefault(.Network, .Info, message)
        #endif
    }
    
    open func logError(_ message: String) {
        #if DEBUG
            LogDefault(.Network, .Info, message)
        #endif
    }
}
