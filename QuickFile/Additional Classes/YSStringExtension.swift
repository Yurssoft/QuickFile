//
//  YSURLExtension.swift
//  QuickFile
//
//  Created by Yurii Boiko on 8/24/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation

extension String
{
    mutating func addingPercentEncoding(_ nextPageToken : String?)
    {
        if let nextPageToken = nextPageToken
        {
            let encodedNextPageToken = CFURLCreateStringByAddingPercentEscapes(
                nil,
                nextPageToken as CFString!,
                nil,
                "!'();:@&=+$,/?%#[]" as CFString!,
                CFStringBuiltInEncodings.ASCII.rawValue
                )!
            self.append("pageToken=\(encodedNextPageToken)&")
        }
    }
}
