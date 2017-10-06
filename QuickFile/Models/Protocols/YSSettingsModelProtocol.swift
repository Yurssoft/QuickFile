//
//  YSSettingsModelProtocol.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/17/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation

protocol YSSettingsModelProtocol {
    var isLoggedIn: Bool {get}

    func logOut() throws
}
