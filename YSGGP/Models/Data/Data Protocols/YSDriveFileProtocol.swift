//
//  YSDriveFileProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/22/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST

protocol YSDriveFileProtocol
{
    var fileName : String { get set} //Book 343
    var fileSize : String { get set} //108.03 MB (47 audio) or 10:18
    var mimeType : String { get set}
    var isAudio : Bool { get set} //If true it is audio if false it is folder
    var fileDriveIdentifier : String { get set}
    var localFilePath : String { get set}
    var modifiedTime : String { get set}
    
    init(file: GTLRDrive_File)
}
