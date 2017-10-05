//
//  YSNSLoggerAdapter.swift
//  QuickFile
//
//  Created by Yurii Boiko on 10/4/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation
import NSLogger

public func LogDriveSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String,
                _ filename: String = #file, lineNumber: Int32 = #line, fnName: String = #function)
{
    Log(domain, level, "-Drive: " + fnName + " " + format)
}

public func LogSearchSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String,
                               _ filename: String = #file, lineNumber: Int32 = #line, fnName: String = #function)
{
    Log(domain, level, "-Search: " + fnName + " " + format)
}

public func LogPlayerSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String,
                              _ filename: String = #file, lineNumber: Int32 = #line, fnName: String = #function)
{
    Log(domain, level, "-Player: " + fnName + " " + format)
}

public func LogPlaylistSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String,
                               _ filename: String = #file, lineNumber: Int32 = #line, fnName: String = #function)
{
    Log(domain, level, "-Playlist: " + fnName + " " + format)
}

public func LogSettingsSubdomain(_ domain: LoggerDomain, _ level: LoggerLevel, _ format: String,
                                 _ filename: String = #file, lineNumber: Int32 = #line, fnName: String = #function)
{
    Log(domain, level, "-Settings: " + fnName + " " + format)
}
