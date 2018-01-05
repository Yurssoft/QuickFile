//
//  YSPlayerCoordinator.swift
//  YSGGP
//
//  Created by Yurii Boiko on 12/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SwiftMessages
import MediaPlayer
import LNPopupController

class YSPlayerCoordinator: YSCoordinatorProtocol {
    var viewModel = YSPlayerViewModel.init()
    fileprivate var tabBarController: UITabBarController?
    fileprivate var popupContentController: YSPlayerController?
    private var isStarted = false

    func start(tabBarController: UITabBarController) {
        if isStarted {
            return
        }
        self.tabBarController = tabBarController
        let model = YSPlaylistAndPlayerModel()
        viewModel.coordinatorDelegate = self
        viewModel.model = model
        YSAppDelegate.appDelegate().playerDelegate = viewModel
        isStarted = true
    }

    func play(file: YSDriveFileProtocol) {
        viewModel.play(file: file)
    }
}

extension YSPlayerCoordinator: YSPlayerViewModelCoordinatorDelegate {
    func showPlayer() {
        DispatchQueue.main.async {
            if self.tabBarController?.popupPresentationState != .hidden {
                return
            }
            let audioSession = AVAudioSession.sharedInstance()
            do {
                if #available(iOS 11.0, *) {
                    try audioSession.setCategory(AVAudioSessionCategoryPlayback, mode: AVAudioSessionModeDefault, routeSharingPolicy: .longForm)
                } else {
                    try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                }
                try audioSession.setActive(true)
            } catch let error as NSError {
                logPlayerSubdomain(.Routing, .Error, "Error seting audio session: " + error.localizedDescriptionAndUnderlyingKey)
            }
            UIApplication.shared.beginReceivingRemoteControlEvents()

            self.popupContentController = self.tabBarController?.storyboard?.instantiateViewController(withIdentifier: YSPlayerController.nameOfClass) as? YSPlayerController
            self.popupContentController?.viewModel = self.viewModel
            self.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: nil)
            self.tabBarController?.popupBar.tintColor = YSConstants.kDefaultBlueColor
            self.tabBarController?.popupBar.subtitleTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.lightGray]
        }
    }

    func hidePlayer() {
        DispatchQueue.main.async {
            if self.tabBarController?.popupPresentationState == .hidden {
                return
            }
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(false)
            } catch let error as NSError {
                logPlayerSubdomain(.Routing, .Error, "Error seting audio session: " + error.localizedDescriptionAndUnderlyingKey)
            }
            UIApplication.shared.endReceivingRemoteControlEvents()
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
    }
}
