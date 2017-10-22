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
import SwiftMessages
import KeychainAccess
import Reachability

class YSCredentialManager {
    static let shared: YSCredentialManager = {
        let instance = YSCredentialManager()
        return instance
    }()

    private init() {
        let keychain = Keychain(service: YSConstants.kTokenKeychainKey)
        let tokenDataUnwrapped = keychain[data: YSConstants.kTokenKeychainItemKey]
        do {
            if let tokenData = tokenDataUnwrapped {
                let token = try JSONDecoder().decode(YSToken.self, from: tokenData)
                self.token = token
            }
        } catch {
            logDefault(.Service, .Error, "Something wrong with token data: " + error.localizedDescription)
        }
    }

    private var token = YSToken()

    private var isValidAccessToken: Bool {
        let isTokenPresent = !token.accessToken.isEmpty
        let isNotTimedOut = token.accessTokenAvailableTo.isLessThanDate(date: Date())
        return isTokenPresent && !isNotTimedOut
    }

    func isPresentRefreshToken() -> Bool {
        return !token.refreshToken.isEmpty
    }

    func setTokens(refreshToken: String, accessToken: String, availableTo: Date) {
        token.refreshToken = refreshToken
        token.accessToken = accessToken
        token.accessTokenAvailableTo = availableTo
        saveTokenToKeychain()
    }

    func setAccessToken(tokenType: String, accessToken: String, availableTo: Date) {
        token.accessTokenTokenType = tokenType
        token.accessToken = accessToken
        token.accessTokenAvailableTo = availableTo
        saveTokenToKeychain()
    }

    private func saveTokenToKeychain() {
        let keychain = Keychain(service: YSConstants.kTokenKeychainKey)
        do {
            let tokenData = try JSONEncoder().encode(token)
            keychain[data: YSConstants.kTokenKeychainItemKey] = tokenData
        } catch {
            logDefault(.Service, .Error, "Something wrong with token data: " + error.localizedDescription)
        }
    }

    private func urlForAccessToken() -> URL {
        let url = "\(YSConstants.kAccessTokenAPIEndpoint)?client_id=\(YSConstants.kDriveClientID)&refresh_token=\(token.refreshToken)&grant_type=refresh_token"
        return URL.init(string: url)!
    }

    func addAccessTokenHeaders(_ request: URLRequest, _ taskIdentifier: String, _ completionHandler: @escaping AccessTokenAddedCompletionHandler) {
        if isValidAccessToken {
            addHeaders(to: request, completionHandler)
            return
        }
        var requestForToken = URLRequest.init(url: urlForAccessToken())
        requestForToken.httpMethod = "POST"

        let accessHeadersTask = URLSession.shared.dataTask(with: requestForToken) { data, response, error in
            if let err = YSNetworkResponseManager.validate(response, error: error) {
                completionHandler(request, err)
                return
            }
            let dict = YSNetworkResponseManager.convertToDictionary(from: data!)
            if let accessToken = dict["access_token"] as? String, let tokenType = dict["token_type"] as? String, let expiresIn = dict["expires_in"] as? NSNumber {
                let availableTo = Date().addingTimeInterval(expiresIn.doubleValue)
                self.setAccessToken(tokenType: tokenType, accessToken: accessToken, availableTo: availableTo)
                self.addHeaders(to: request, completionHandler)
            }
        }
        accessHeadersTask.taskDescription = taskIdentifier
        accessHeadersTask.resume()
    }

    private func addHeaders(to request: URLRequest, _ completionHandler: @escaping AccessTokenAddedCompletionHandler) {
        var request = request
        if token.accessTokenTokenType.isEmpty {
            request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
            completionHandler(request, nil)
        } else {
            request.setValue("\(token.accessTokenTokenType) \(token.accessToken)", forHTTPHeaderField: "Authorization")
            completionHandler(request, nil)
        }
    }

    class var isLoggedIn: Bool {
        let isLoggedIn = !YSCredentialManager.shared.token.refreshToken.isEmpty && Auth.auth().currentUser != nil
        return isLoggedIn
    }

    class func logOut() throws {
        GIDSignIn.sharedInstance().signOut()
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            logDefault(.Service, .Error, "Could not log out: " + error.localizedDescriptionAndUnderlyingKey)
        }
        let keychain = Keychain(service: YSConstants.kTokenKeychainKey)
        keychain[data: YSConstants.kTokenKeychainItemKey] = Data()
        shared.token = YSToken()
        let message = YSError(errorType: YSErrorType.notLoggedInToDrive, messageType: Theme.success, title: "Success", message: "Logged out from Drive", buttonTitle: "Login", debugInfo: "")
        throw message
    }
}
