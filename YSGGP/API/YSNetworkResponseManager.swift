//
//  YSNetworkResponseManager.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

class YSNetworkResponseManager
{
    class func validate(_ response : URLResponse?, error: Error?) -> YSErrorProtocol?
    {
        if let httpResponse = response as? HTTPURLResponse
        {
            let networkErrorDescription = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            switch httpResponse.statusCode
            {
            case 200...299:
                return nil
                
            default:
                let errorMessage = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.warning, title: "Warning", message: "Could not get list", buttonTitle: "Try again", debugInfo: networkErrorDescription)
                return errorMessage
            }
        }
        if let er = error
        {
            let errorMessage = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.warning, title: "Warning", message: "Could not get list", buttonTitle: "Try again", debugInfo: er.localizedDescription)
            return errorMessage
        }
        let errorMessage = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.warning, title: "Error", message: "Unkown error", buttonTitle: "Try again", debugInfo: "UNKOWN ERROR !!! ___---+++111")
        return errorMessage
    }
    
    class func validateDownloadTask(_ response : URLResponse?, error: Error?, fileName : String) -> YSErrorProtocol?
    {
        if let httpResponse = response as? HTTPURLResponse
        {
            let networkErrorDescription = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            switch httpResponse.statusCode
            {
            case 200...299:
                return nil
                
            default:
                let errorMessage = YSError(errorType: YSErrorType.couldNotDownloadFile, messageType: Theme.error, title: "Error", message: "Could not download file \(fileName)", buttonTitle: "Try again", debugInfo: networkErrorDescription)
                return errorMessage
            }
        }
        if let er = error
        {
            let errorMessage = YSError(errorType: YSErrorType.couldNotDownloadFile, messageType: Theme.error, title: "Error", message: "Could not download file \(fileName)", buttonTitle: "Try again", debugInfo: er.localizedDescription)
            return errorMessage
        }
        return nil
    }
    
    class func convertToDictionary(from data: Data?) -> [String: Any]
    {
        if let data = data
        {
            do
            {
                let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
                return json as! [String: Any]
            }
            catch
            {
                return ["" : NSNull()]
            }
        }
        else
        {
            return ["" : NSNull()]
        }
    }
}
