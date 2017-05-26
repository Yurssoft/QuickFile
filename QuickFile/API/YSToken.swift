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
    //AccessToken
    var accessToken : String = ""
    var accessTokenTokenType : String = ""
    var accessTokenAvailableTo : Date = Date().addDays(days: -200)
    
    //RefreshToken
    var refreshToken : String = ""
}
