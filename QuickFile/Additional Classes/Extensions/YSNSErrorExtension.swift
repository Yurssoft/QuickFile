//
//  YSNSErrorExtension.swift
//  QuickFile
//
//  Created by Yurii Boiko on 10/6/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation

extension NSError {
    var localizedDescriptionAndUnderlyingKey: String {
        return "\(self.localizedDescription) - \(self.userInfo.value(forKey: NSUnderlyingErrorKey, defaultValue: "")) "
    }
}
