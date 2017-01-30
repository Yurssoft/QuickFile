//
//  YSDictionaryExtension.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/18/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

public extension Dictionary
{
    internal func toYSFile() -> YSDriveFileProtocol
    {
        let object = YSDriveFile()
        for key in keys
        {
            let val = self[key]
            let propertyKey = key as! String
            if propertyKey == "folder"
            {
                let folder = YSFolder()
                let value = val as! [String : String]
                folder.folderID = value["folderID"]!
                folder.folderName = value["folderName"]!
                object.setValue(folder, forKey: propertyKey)
            }
            else
            {
                object.setValue(val, forKey: propertyKey)
            }
        }
        return object
    }
    
    internal func toYSToken() -> YSToken
    {
        let object = YSToken()
        for key in keys
        {
            let val = self[key]
            object.setValue(val, forKey: key as! String)
        }
        return object
    }
}
