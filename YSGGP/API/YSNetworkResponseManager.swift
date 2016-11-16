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
    class func validate(_ response : URLResponse, error: Error?) -> YSErrorProtocol?
    {
        if let er = error
        {
            let errorMessage = YSError(errorType: YSErrorType.couldNotGetFileList, messageType: Theme.warning, title: "Warning", message: "Could not get list", buttonTitle: "Try again", debugInfo: er.localizedDescription)
            return errorMessage
        }
        let httpResponse = response as! HTTPURLResponse
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
    
    class func convertToDictionary(from data: Data?) -> [String: [String: Any]]
    {
        if let data = data
        {
            do
            {
                let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments)
                return json as! [String: [String: Any]]
            }
            catch
            {
                return ["" : ["": NSNull()]]
            }
        }
        else
        {
            return ["" : ["": NSNull()]]
        }
    }
}
