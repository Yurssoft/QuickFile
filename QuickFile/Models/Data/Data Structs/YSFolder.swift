//
//  YSFolderModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 1/3/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation

struct YSFolder {
    var folderName: String = ""
    var folderID: String = ""

    static func rootFolder() -> YSFolder {
        var folder = YSFolder()
        folder.folderID = "root"
        folder.folderName = "Root"
        return folder
    }

    static func searchFolder() -> YSFolder {
        var folder = YSFolder()
        folder.folderID = "search"
        folder.folderName = "Search"
        return folder
    }
}
