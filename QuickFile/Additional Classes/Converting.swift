//
//  Converting.swift
//  QuickFile
//
//  Created by Yurii Boiko on 5/26/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation

public func toDictionary<T>(type: T) -> [String: Any]
{
    let mirroredObject = Mirror(reflecting: type)
    
    var objectDictionary = [String: Any]()
    for (_, attr) in mirroredObject.children.enumerated()
    {
        if let property_name = attr.label as String!, property_name == "folder", let folderObj = attr.value as? YSFolder
        {
            objectDictionary[property_name] = toDictionary(type: folderObj)
        }
        else if let property_name = attr.label as String!
        {
            objectDictionary[property_name] = attr.value
        }
    }
    return objectDictionary
}
