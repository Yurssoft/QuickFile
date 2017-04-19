//
//  ACKDefaultLogger.swift
//  Pods
//
//  Created by Jan Mísař on 02.08.16.
//
//

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
