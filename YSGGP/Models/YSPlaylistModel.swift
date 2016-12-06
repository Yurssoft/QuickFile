//
//  YSPlaylistModel.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/6/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

class YSPlaylistModel : YSPlaylistModelProtocol
{
    func getAllFiles(_ completionHandler: PlaylistCompletionHandler)
    {
        YSDatabaseManager.allFiles { (_ _) in
            print("YAY")
        }
    }
}
