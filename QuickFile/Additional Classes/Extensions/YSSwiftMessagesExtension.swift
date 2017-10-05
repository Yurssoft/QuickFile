//
//  SwiftMessagesExtension.swift
//  QuickFile
//
//  Created by Yurii Boiko on 9/9/17.
//  Copyright © 2017 Yurii Boiko. All rights reserved.
//

import Foundation
import SwiftMessages

extension SwiftMessages
{
    class func showNoInternetError(_ error: YSErrorProtocol)
    {
        let statusBarMessage = MessageView.viewFromNib(layout: .statusLine)
        statusBarMessage.backgroundView.backgroundColor = UIColor.orange
        statusBarMessage.bodyLabel?.textColor = UIColor.white
        statusBarMessage.configureContent(body: error.message)
        statusBarMessage.tapHandler =
        { _ in
            SwiftMessages.hide(id: YSConstants.kOffineStatusBarMessageID)
        }
        var messageConfig = defaultConfig
        messageConfig.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        messageConfig.preferredStatusBarStyle = .lightContent
        messageConfig.duration = .forever
        statusBarMessage.id = YSConstants.kOffineStatusBarMessageID
        show(config: messageConfig, view: statusBarMessage)
    }
    
    class func createMessage<T: MessageView>(_ error: YSErrorProtocol) -> T
    {
        let message = MessageView.viewFromNib(layout: .cardView)
        message.configureTheme(error.messageType)
        message.configureDropShadow()
        message.configureContent(title: error.title, body: error.message)
        message.button?.setTitle(error.buttonTitle, for: UIControlState.normal)
        return message as! T
    }
    
    class func showDefaultMessage(_ message: MessageView)
    {
        var messageConfig = SwiftMessages.Config()
        messageConfig.duration = YSConstants.kMessageDuration
        messageConfig.ignoreDuplicates = false
        messageConfig.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        SwiftMessages.hide(id: YSConstants.kOffineStatusBarMessageID)
        SwiftMessages.show(config: messageConfig, view: message)
    }
}
