//
//  YSConstants.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import UIKit
import SwiftMessages

typealias CompletionHandler = () -> Swift.Void
typealias FilesCH = (_ files: [YSDriveFileProtocol]) -> Swift.Void
typealias ErrorCH = (_ error: YSErrorProtocol?) -> Swift.Void
typealias AccessTokenAddedCH = (_ request: URLRequest, _ error: YSErrorProtocol?) -> Swift.Void
//                                      //files              //error           //next page token
typealias AllFilesCH = ([YSDriveFileProtocol], YSErrorProtocol?, String?) -> Swift.Void
                                                        //files                //current playing    //error
typealias AllFilesAndCurrentPlayingCH = ([YSDriveFileProtocol], YSDriveFileProtocol?, YSErrorProtocol?) -> Swift.Void
typealias FilesListDictDownloadedCH = (_ filesDictionary: [String: Any]?, _ error: YSErrorProtocol?) -> Swift.Void
typealias FilesListMetadataDownloadedCH = (_ filesList: YSFiles, _ error: YSErrorProtocol?) -> Swift.Void //CH - completion handler

struct YSConstants {
    static let kDriveClientID = "416980241627-jl0l2kt36fd7soan5k8hlhtsgfkoblns.apps.googleusercontent.com"
    static let kStoryboardName = "Main"
    static let kDriveEmbededSegue = "YSDriveViewControllerSegue"
    static let kSettingsEmbededSegue = "YSSettingsViewControllerSegue"
    static let kDriveAPIKey = "AIzaSyCMsksSn6-1FzYhN49uDAzN83HGvFVXqaU"
    static let kDriveAPIEndpoint = "https://www.googleapis.com/drive/v3/"
    static let kAccessTokenAPIEndpoint = "https://www.googleapis.com/oauth2/v4/token"
    static let kObtainUserAuthorizationAPIEndpoint = "https://accounts.google.com/o/oauth2/v2/auth"
    static let kTokenKeychainKey = "kTokenKeychainKey"
    static let kTokenKeychainItemKey = "kTokenKeychainItemKey"
    static let kDriveScopes = ["https://www.googleapis.com/auth/drive.readonly"]
    static let kFirstPageToken = "kFirstPageToken"
    static let kDriveSearchNavigation = "YSDriveSearchControllerNavigation"
    static let kOffineStatusBarMessageID = "kOffineStatusBarMessageID"
    static let kCellHeight = CGFloat(50.0)
    static let kHeaderHeight = CGFloat(28.0)
    static let kPageSize = 100
    static let kNumberOfLogsStored = 19
    static let noSpaceLeftOnDiskErrorSystemCode = 28
    static let noSpaceLeftOnDiskErrorDomain = "NSPOSIXErrorDomain"
    static let kNoInternetSystemCode = -1009
    static let kDefaultBlueColor = UIColor(red: 23/255.0, green: 156/255.0, blue: 209/255.0, alpha: 1.0)
    static let kDefaultBarColor = UIColor(red: 254/255.0, green: 213/255.0, blue: 165/255.0, alpha: 1.0)
    static let kMessageDuration = SwiftMessages.Duration.automatic
    static let localFilePathForDownloadingFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let cacheFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    static let logsFolder = cacheFolder.appendingPathComponent("AppLogs")
    static let kCellularAccessAllowedUserDefaultKey = "kCellularAccessAllowedUserDefaultKey"
    static let kDeveloperMail = "yurii.boiko.s@gmail.com"
    static let kProjectURL = "https://github.com/Yurssoft/QuickFile"
}

enum YSErrorType {
    case none
    case couldNotGetFileList
    case cancelledLoginToDrive
    case couldNotLoginToDrive
    case loggedInToToDrive
    case notLoggedInToDrive
    case couldNotLogOutFromDrive
    case couldNotDownloadFile
}
