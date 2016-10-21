//
//  YSDriveItem.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/22/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSDriveFileProtocol
{
    var fileName : String { get } //Book 343
    var fileSize : String { get } //108.03 MB (47 audio) or 10:18
    var mimeType : String { get }
    var isAudio : Bool { get } //If true it is audio if false it is folder
    var fileDriveIdentifier : String { get } 
}
