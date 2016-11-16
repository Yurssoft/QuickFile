//
//  YSRefreshToken.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSToken
{
    struct RefreshToken
    {
        var refreshToken : String
        var clientID : String
    }
    
    struct AccessToken
    {
        var accessToken : String
        var tokenType : String
        var availableTo : Date
        
//        {
//            "access_token": "ya29.Ci8SAzMH13iQa1t1buFUtN_v8X5wirj-bEmUM4VaaHJwPrh4ZUF5SiBIqMlxOU_58g",
//            "token_type": "Bearer",
//            "expires_in": 3600 //(availableTo)
//        }
    }
    
    var refreshToken : RefreshToken
    var accessToken : AccessToken
}
