//
//  YSDateExtension.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

extension Date
{
    func isGreaterThanDate(date: Date) -> Bool
    {
        var isGreater = false
        if self.compare(date) == ComparisonResult.orderedDescending
        {
            isGreater = true
        }
        return isGreater
    }
    
    func isLessThanDate(date: Date) -> Bool
    {
        var isLess = false
        if self.compare(date) == ComparisonResult.orderedAscending
        {
            isLess = true
        }
        return isLess
    }
    
    func equalToDate(date: Date) -> Bool
    {
        var isEqualTo = false
        if self.compare(date) == ComparisonResult.orderedSame
        {
            isEqualTo = true
        }
        return isEqualTo
    }
    
    func addDays(days: Int) -> Date
    {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: days, to: self)
        return date!
    }
    
    func addHours(hours: Int) -> Date
    {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .hour, value: hours, to: self)
        return date!
    }
    
    func addMinutes(minutes: Int) -> Date
    {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .hour, value: minutes, to: self)
        return date!
    }
}
