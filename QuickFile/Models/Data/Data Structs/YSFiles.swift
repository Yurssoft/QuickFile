//
//  YSFiles.swift
//  QuickFile
//
//  Created by Yurii Boiko on 10/13/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSFiles: Decodable {
    var files: [YSDriveFile]
    var nextPageToken: String?
}
