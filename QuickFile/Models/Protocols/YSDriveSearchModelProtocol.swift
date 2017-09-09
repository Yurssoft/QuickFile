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
    
    func download(_ file : YSDriveFileProtocol)
    
    func stopDownload(_ file : YSDriveFileProtocol)
    
    func download(for file: YSDriveFileProtocol) -> YSDownloadProtocol?
}
