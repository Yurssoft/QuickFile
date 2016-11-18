//
//  YSConstants.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

typealias CompletionHandler = (YSErrorProtocol?) -> Swift.Void

struct YSConstants
{
    static let kDriveClientID = "416980241627-f5pe5hit7mjggbs1sj6jlth83ci9g91o.apps.googleusercontent.com" 
    static let kStoryboardName = "Main"
    static let kDriveEmbededSegue = "YSDriveViewControllerSegue"
    static let kSettingsEmbededSegue = "YSSettingsViewControllerSegue"
    static let kDriveAPIKey = "AIzaSyCMsksSn6-1FzYhN49uDAzN83HGvFVXqaU"
    static let kDriveAPIEndpoint = "https://www.googleapis.com/drive/v3/"
    static let kAccessTokenAPIEndpoint = "https://www.googleapis.com/oauth2/v4/token"
    static let kTokenKeychainKey = "kTokenKeychainKey"
    static let kTokenKeychainItemKey = "kTokenKeychainItemKey"
    static let kDriveScopes = ["https://www.googleapis.com/auth/drive.readonly"]
}

enum YSErrorType
{
    case none
    case couldNotGetFileList
    case cancelledLoginToDrive
    case couldNotLoginToDrive
    case loggedInToToDrive
    case notLoggedInToDrive
    case couldNotLogOutFromDrive
    case couldNotDownloadFile
}
