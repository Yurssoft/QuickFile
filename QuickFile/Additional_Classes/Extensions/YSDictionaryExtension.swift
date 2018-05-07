//
//  YSDictionaryExtension.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/18/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import CodableFirebase

extension Dictionary where Key == String, Value == Any {
    mutating func toYSFile() -> YSDriveFileProtocol {
        var ysFile = YSDriveFile()
        
        migrateDict()
        
        do {
            let model = try FirebaseDecoder().decode(YSDriveFile.self, from: self)
            ysFile = model
        } catch let error {
            logDefault(.DB, .Error, "Error decoding: \(error.localizedDescription)")
        }
        return ysFile
    }
    
    mutating func migrateDict() {
        var dict = self
        //migration
        //migration keys: fileDriveIdentifier -> id, fileName -> name, fileSize -> size
        if let migratedValue = dict["fileDriveIdentifier"] {
            dict["id"] = migratedValue
            dict["fileDriveIdentifier"] = nil
        }
        if let migratedValue = dict["fileName"] {
            dict["name"] = migratedValue
            dict["fileName"] = nil
        }
        if let migratedValue = dict["fileSize"] {
            dict["size"] = migratedValue
            dict["fileSize"] = nil
        }
        self = dict
    }
}

extension Dictionary where Value == Any {
    subscript<T>(forKey key: Key, defaultV: @autoclosure () -> T) -> T {
        get {
            guard let value = self[key] as? T else {
                return defaultV()
            }
            return value
        }
    }
}
