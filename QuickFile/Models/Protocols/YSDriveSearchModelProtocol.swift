//
//  YSDriveSearchModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 2/17/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSDriveSearchModelProtocol
{
    func getFiles(for searchTerm: String, sectionType: YSSearchSectionType, nextPageToken: String?, _ completionHandler: @escaping AllFilesCompletionHandler)
    
    func getAllFiles(_ completionHandler: @escaping AllFilesCompletionHandler)
    
    func download(_ fileDriveIdentifier: String)
    
    func stopDownload(_ fileDriveIdentifier: String)
    
    func download(for fileDriveIdentifier: String) -> YSDownloadProtocol?
    
    func upfateFileGeneralInfo(for file: YSDriveFileProtocol)
}
