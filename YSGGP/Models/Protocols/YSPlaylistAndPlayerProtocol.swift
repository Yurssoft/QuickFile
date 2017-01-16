//
//  YSPlaylistModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/6/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

typealias PlaylistAndPlayerCompletionHandler = ([YSDriveFileProtocol], YSDriveFileProtocol?, YSErrorProtocol?) -> Swift.Void

protocol YSPlaylistAndPlayerModelProtocol
{
    func allFiles(_ completionHandler: @escaping PlaylistAndPlayerCompletionHandler)
}
