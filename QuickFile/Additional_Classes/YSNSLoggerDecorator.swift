//
//  YSNSLoggerAdapter.swift
//  QuickFile
//
//  Created by Yurii Boiko on 10/4/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation
import NSLogger

public func logDriveSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String, _ name: String = #file, lineNumber: Int32 = #line, fnName: String = #function) {
    Log(domain, level, "-Drive: " + fnName + " " + format, name, lineNumber: lineNumber, fnName: fnName)
}

public func logSearchSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String, _ name: String = #file, lineNumber: Int32 = #line, fnName: String = #function) {
    Log(domain, level, "-Search: " + fnName + " " + format, name, lineNumber: lineNumber, fnName: fnName)
}

public func logPlayerSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String, _ name: String = #file, lineNumber: Int32 = #line, fnName: String = #function) {
    Log(domain, level, "-Player: " + fnName + " " + format, name, lineNumber: lineNumber, fnName: fnName)
}

public func logPlaylistSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String, _ name: String = #file, lineNumber: Int32 = #line, fnName: String = #function) {
    Log(domain, level, "-Playlist: " + fnName + " " + format, name, lineNumber: lineNumber, fnName: fnName)
}

public func logSettingsSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String, _ name: String = #file, lineNumber: Int32 = #line, fnName: String = #function) {
    Log(domain, level, "-Settings: " + fnName + " " + format, name, lineNumber: lineNumber, fnName: fnName)
}

public func logDefault(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String, _ name: String = #file, lineNumber: Int32 = #line, fnName: String = #function) {
    Log(domain, level, fnName + " :  " + format, name, lineNumber: lineNumber, fnName: fnName)
}
