//
//  YSPlaylistModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/6/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

typealias PlaylistCompletionHandler = ([YSDriveFileProtocol], [YSDriveFileProtocol], YSErrorProtocol?) -> Swift.Void

protocol YSPlaylistModelProtocol
{
    func allFiles(_ completionHandler: @escaping PlaylistCompletionHandler)
}
