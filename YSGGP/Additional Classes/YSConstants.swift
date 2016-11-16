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
    static let kDriveKeychainAuthorizerName = "Drive API"
    static let kDriveClientID = "416980241627-f5pe5hit7mjggbs1sj6jlth83ci9g91o.apps.googleusercontent.com"
    
//    // Authorization scopes
//    
//    NSString * const kGTLRAuthScopeDrive                 = @"https://www.googleapis.com/auth/drive";
//    NSString * const kGTLRAuthScopeDriveAppdata          = @"https://www.googleapis.com/auth/drive.appdata";
//    NSString * const kGTLRAuthScopeDriveFile             = @"https://www.googleapis.com/auth/drive.file";
//    NSString * const kGTLRAuthScopeDriveMetadata         = @"https://www.googleapis.com/auth/drive.metadata";
//    NSString * const kGTLRAuthScopeDriveMetadataReadonly = @"https://www.googleapis.com/auth/drive.metadata.readonly";
//    NSString * const kGTLRAuthScopeDrivePhotosReadonly   = @"https://www.googleapis.com/auth/drive.photos.readonly";
//    NSString * const kGTLRAuthScopeDriveReadonly         = @"https://www.googleapis.com/auth/drive.readonly";
//    NSString * const kGTLRAuthScopeDriveScripts          = @"https://www.googleapis.com/auth/drive.scripts";  
    
    static let kDriveScopes = ["https://www.googleapis.com/auth/drive.readonly"]
    static let kStoryboardName = "Main"
    static let kDriveEmbededSegue = "YSDriveViewControllerSegue"
    static let kSettingsEmbededSegue = "YSSettingsViewControllerSegue"
    static let kDriveAPIKey = "AIzaSyCMsksSn6-1FzYhN49uDAzN83HGvFVXqaU"
    static let kDriveAPIEndpoint = "https://www.googleapis.com/drive/v3/"
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
