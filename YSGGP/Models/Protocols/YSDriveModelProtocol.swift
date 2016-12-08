//
//  YSDriveModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/23/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

typealias DownloadFileProgressHandler = (_ download : YSDownloadProtocol) -> Swift.Void
typealias DownloadCompletionHandler = (_ download : YSDownloadProtocol,_ error: YSErrorProtocol?) -> Swift.Void
typealias DriveCompletionHandler = ([YSDriveFileProtocol], YSErrorProtocol?) -> Swift.Void

protocol YSDriveModelProtocol
{
    var isLoggedIn : Bool {get}
    
    func getFiles(_ completionHandler: @escaping DriveCompletionHandler)
    
    func download(_ file : YSDriveFileProtocol, _ progressHandler: @escaping DownloadFileProgressHandler, completionHandler : @escaping DownloadCompletionHandler)
    
    func stopDownload(_ file : YSDriveFileProtocol)
    
    func download(for file: YSDriveFileProtocol) -> YSDownloadProtocol?
}
