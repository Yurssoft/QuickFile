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
import Reqres

class YSFilesMetadataDownloader {
    class func downloadFilesList(for requestURL: String, _ taskIdentifier: String, _ completionHandler: FilesListMetadataDownloadedCompletionHandler? = nil) {
        let reqURL = URL.init(string: requestURL)
        let request = URLRequest.init(url: reqURL!)
        YSCredentialManager.shared.addAccessTokenHeaders(request, taskIdentifier) { request, error in
            if let err = error {
                completionHandler!(["": ["": NSNull()]], err)
                return
            }
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let err = YSNetworkResponseManager.validate(response, error: error) {
                    completionHandler!(["": ["": NSNull()]], err)
                    return
                }
                let dict = YSNetworkResponseManager.convertToDictionary(from: data!)
                completionHandler!(dict, nil)
            }
            task.taskDescription = taskIdentifier
            task.resume()
        }
    }
    
    class func downloadFiles(for requestURL: String, _ taskIdentifier: String, _ completion: FilesListMetadataDownloadedCH? = nil) {
        let reqURL = URL.init(string: requestURL)
        let request = URLRequest.init(url: reqURL!)
        YSCredentialManager.shared.addAccessTokenHeaders(request, taskIdentifier) { request, error in
            if let err = error {
                completion!(YSFiles(files: [], nextPageToken: nil), err)
                return
            }
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let err = YSNetworkResponseManager.validate(response, error: error) {
                    completion!(YSFiles(files: [], nextPageToken: nil), err)
                    return
                }
                var debugInfo = ""
                do {
                    if let data = data {
                        let files = try JSONDecoder().decode(YSFiles.self, from: data)
                        completion!(files, nil)
                        return
                    }
                    debugInfo = "Data is empty"
                } catch DecodingError.dataCorrupted(let context) {
                    debugInfo = "Something wrong with files data: \(context)"
                } catch DecodingError.keyNotFound(let key, let context) {
                    debugInfo = "Something wrong with files data: \(context) , \(key)"
                } catch DecodingError.typeMismatch(let type, let context) {
                    debugInfo = "Something wrong with files data: \(context) , \(type)"
                } catch DecodingError.valueNotFound(let value, let context) {
                    debugInfo = "Something wrong with files data: \(context) , \(value)"
                } catch {
                    debugInfo = error.localizedDescription
                }
                if debugInfo.count > 0 {
                    logDefault(.Service, .Error, "Something wrong with files data: " + debugInfo)
                    let ysError = YSError(errorType: .couldNotGetFileList, messageType: Theme.error, title: "Data error", message: "Wrong response", buttonTitle: "Try again", debugInfo: debugInfo)
                    completion!(YSFiles(files: [], nextPageToken: nil), ysError)
                }
            }
            task.taskDescription = taskIdentifier
            task.resume()
        }
    }

    class func cancelTaskWithIdentifier(taskIdentifier: String) {
        URLSession.shared.getAllTasks { tasks in
            for task in tasks where task.taskDescription == taskIdentifier {
                task.cancel()
            }
        }
    }
}
