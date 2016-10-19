//
//  YSConstants.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleAPIClient

struct YSConstants
{
    static let kDriveKeychainItemName = "Drive API"
    static let kDriveClientID = "416980241627-f5pe5hit7mjggbs1sj6jlth83ci9g91o.apps.googleusercontent.com"
    static let kDriveScopes = [kGTLAuthScopeDriveReadonly]
    static let kStoryboardName = "Main"
    static let kDriveEmbededSegue = "YSDriveViewControllerSegue"
    static let kSettingsEmbededSegue = "YSSettingsViewControllerSegue"
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
}