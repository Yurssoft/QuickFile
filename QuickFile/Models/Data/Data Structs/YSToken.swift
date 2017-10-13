//
//  YSRefreshToken.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSToken: Codable {
    //AccessToken
    var accessToken = ""
    var accessTokenTokenType = ""
    var accessTokenAvailableTo = Date().addDays(days: -200)

    //RefreshToken
    var refreshToken = ""
}
