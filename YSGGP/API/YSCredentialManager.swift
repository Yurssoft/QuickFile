//
//  YSCredentialManager.swift
//  YSGGP
//
//  Created by Yurii Boiko on 11/16/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import Foundation
import GoogleSignIn
import Firebase

class YSCredentialManager
{
    static var isLoggedIn : Bool
    {
        return GIDSignIn.sharedInstance().currentUser != nil && FIRAuth.auth()!.currentUser != nil
    }
    
    static func logOut()
    {
        GIDSignIn.sharedInstance().signOut()
        try? FIRAuth.auth()!.signOut()
    }
}
