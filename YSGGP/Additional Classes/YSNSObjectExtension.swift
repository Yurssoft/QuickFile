//
//  YSStringFromClass.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/29/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

public extension NSObject
{
    public class var nameOfClass: String
    {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public func toDictionary() -> [String: Any]
    {
        let mirroredObject = Mirror(reflecting: self)
        
        var objectDictionary = [String: Any]()
        for (_, attr) in mirroredObject.children.enumerated()
        {
            if let property_name = attr.label as String!
            {
                objectDictionary[property_name] = attr.value
            }
        }
        return objectDictionary
    }
}
