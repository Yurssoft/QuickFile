//
//  YSNetworkResponseManager.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import HTTPStatusCodes

class YSNetworkResponseManager
{
    static func validate(_ response : URLResponse) -> YSErrorProtocol?
    {
        let httpResponse = response as! HTTPURLResponse
        switch httpResponse.statusCode
        {
            default
            break
        }
        return nil
    }
}
