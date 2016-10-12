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
}
