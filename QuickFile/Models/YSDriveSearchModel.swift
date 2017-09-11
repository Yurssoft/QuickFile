//
//  YSDriveSearchModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 2/17/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation

class YSDriveSearchModel : YSDriveSearchModelProtocol
{
    private let taskUIID = UUID().uuidString
    deinit
    {
        YSFilesMetadataDownloader.shared.cancelTaskWithIdentifier(taskIdentifier: taskUIID)
    }
    
    func getFiles(for searchTerm: String, sectionType: YSSearchSectionType, nextPageToken: String?, _ completionHandler: @escaping AllFilesCompletionHandler)
    {
        var url = "\(YSConstants.kDriveAPIEndpoint)files?"
        url.addingPercentEncoding(nextPageToken)
        switch sectionType
        {
        case .all:
            url += "corpus=user&orderBy=folder,name&pageSize=\(YSConstants.kPageSize)&q=SEARCH_CONTAINS(mimeType+contains+'folder'+or+mimeType+contains+'audio')+and+trashed=false&spaces=drive&fields=nextPageToken,files(id,+name,+size,+mimeType)&key=AIzaSyCMsksSn6-1FzYhN49uDAzN83HGvFVXqaU"
            break
        case .files:
            url += "corpus=user&orderBy=folder,name&pageSize=\(YSConstants.kPageSize)&q=SEARCH_CONTAINSmimeType+contains+'audio'+and+trashed=false&spaces=drive&fields=nextPageToken,files(id,+name,+size,+mimeType)&key=AIzaSyCMsksSn6-1FzYhN49uDAzN83HGvFVXqaU"
            break
        case .folders:
            url += "corpus=user&orderBy=folder,name&pageSize=\(YSConstants.kPageSize)&q=SEARCH_CONTAINSmimeType+contains+'folder'+and+trashed=false&spaces=drive&fields=nextPageToken,files(id,+name,+size,+mimeType)&key=AIzaSyCMsksSn6-1FzYhN49uDAzN83HGvFVXqaU"
            break
        }
        let searchTermClean = searchTerm.replacingOccurrences(of: " ", with: "")
        if searchTermClean.characters.count > 0
        {
            let searchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
            let contains = "name+contains+'\(searchTerm)'+and+"
            url = url.replacingOccurrences(of: "SEARCH_CONTAINS", with: contains)
        }
        else
        {
            url = url.replacingOccurrences(of: "SEARCH_CONTAINS", with: "")
        }
        YSFilesMetadataDownloader.shared.downloadFilesList(for: url, taskUIID)
        { filesDictionary, error in
            if let err = error
            {
                let yserror = err as! YSError
                completionHandler([], yserror, "")
                return
            }
            guard let filesDictionary = filesDictionary else { return completionHandler([], YSError(), "") }
            var ysFiles = [YSDriveFileProtocol]()
            var nextPageToken : String?
            for fileKey in filesDictionary.keys
            {
                switch fileKey
                {
                case "nextPageToken":
                    let token = filesDictionary[fileKey] as! String
                    nextPageToken = token
                    continue
                    
                case "files":
                    
                    let files = filesDictionary[fileKey] as! [Any]
                    
                    for file in files
                    {
                        let fileDict = file as! [String : Any]
                        
                        let ysFile = YSDriveFile.init(fileName: fileDict["name"] as! String?,
                                                      fileSize: fileDict["size"] as! String?,
                                                      mimeType: fileDict["mimeType"] as! String?,
                                                      fileDriveIdentifier: fileDict["id"] as! String?,
                                                      folderName: "",
                                                      folderID: "",
                                                      playedTime : "",
                                                      isPlayed : false,
                                                      isCurrentlyPlaying : false,
                                                      isDeletedFromDrive : false,
                                                      pageToken: "")
                        ysFiles.append(ysFile)
                    }
                    continue
                    
                    default:
                    break
                }
            }
            completionHandler(ysFiles, YSError(), nextPageToken)
        }
    }
    
    func getAllFiles(_ completionHandler: @escaping AllFilesCompletionHandler)
    {
        YSDatabaseManager.getAllFiles(completionHandler)
    }
    
    func download(for fileDriveIdentifier: String) -> YSDownloadProtocol?
    {
        return YSAppDelegate.appDelegate().fileDownloader.download(for: fileDriveIdentifier)
    }
    
    func download(_ fileDriveIdentifier: String)
    {
        YSAppDelegate.appDelegate().fileDownloader.download(fileDriveIdentifier: fileDriveIdentifier)
    }
    
    func upfateFileGeneralInfo(for file: YSDriveFileProtocol)
    {
        YSDatabaseManager.updateGenaralFileInfo(file: file)
    }
    
    func stopDownload(_ fileDriveIdentifier: String)
    {
        YSAppDelegate.appDelegate().fileDownloader.cancelDownloading(fileDriveIdentifier: fileDriveIdentifier)
    }
}
