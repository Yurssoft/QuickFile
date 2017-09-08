//
//  ReqresDefaultLogger.swift
//  QuickFile
//
//  Created by Yurii Boiko on 9/8/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Reqres
import SwiftyBeaver

open class ReqresDefaultLogger: ReqresLogging {
    
    open var logLevel: LogLevel = .verbose
    
    open func logVerbose(_ message: String) {
        let log = SwiftyBeaver.self
        log.info(message)
    }
    
    open func logLight(_ message: String) {
        let log = SwiftyBeaver.self
        log.info(message)
    }
    
    open func logError(_ message: String) {
        let log = SwiftyBeaver.self
        log.info(message)
    }
}
