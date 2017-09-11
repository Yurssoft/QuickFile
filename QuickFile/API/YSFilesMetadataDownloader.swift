//
//  YSFilesMetadataDownloader.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages
import SystemConfiguration

class YSFilesMetadataDownloader
{
    static let shared = YSFilesMetadataDownloader()
    let urlSession : URLSession
    
    private init()
    {
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func downloadFilesList(for requestURL: String, _ taskIdentifier: String, _ completionHandler: FilesListMetadataDownloadedCompletionHandler? = nil)
    {
        let reqURL = URL.init(string: requestURL)
        let request = URLRequest.init(url: reqURL!)
        let accessHeadersTask = YSCredentialManager.shared.addAccessTokenHeaders(request, urlSession)
        { [weak self] request, error in
            if let err = error
            {
                completionHandler!(["" : ["": NSNull()]], err)
                return
            }
            let task = self?.urlSession.dataTask(with: request)
            { data, response, error in
                if let err = YSNetworkResponseManager.validate(response, error: error)
                {
                    completionHandler!(["" : ["": NSNull()]], err)
                    return
                }
                let dict = YSNetworkResponseManager.convertToDictionary(from: data!)
                completionHandler!(dict, nil)
            }
            task?.taskDescription = taskIdentifier
            task?.resume()
        }
        accessHeadersTask?.taskDescription = taskIdentifier
        accessHeadersTask?.resume()
    }
    
    func cancelTaskWithIdentifier(taskIdentifier: String)
    {
        urlSession.getAllTasks
        { tasks in
            for task in tasks
            {
                if task.taskDescription == taskIdentifier
                {
                    task.cancel()
                }
            }
        }
    }
}
