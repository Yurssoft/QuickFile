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

class YSPlayerCoordinator: YSCoordinatorProtocol
{
    //TODO: Consider using Carthage or git submodule for LNPopupController
    func start() { }
    
    fileprivate var viewModel = YSPlayerViewModel()
    fileprivate var tabBarController: UITabBarController?
    fileprivate var popupContentController: YSPlayerController?
    
    func start(tabBarController: UITabBarController)
    {
        self.tabBarController = tabBarController
        let model = YSPlaylistAndPlayerModel()
        viewModel.coordinatorDelegate = self
        viewModel.model = model
    }
    
    func play(file: YSDriveFileProtocol)
    {
        let model = YSPlaylistAndPlayerModel()
        viewModel.model = model
        viewModel.play(file: file)
    }
}

extension YSPlayerCoordinator : YSPlayerViewModelCoordinatorDelegate
{
    func showPlayer()
    {
        DispatchQueue.main.async
        {
            if self.tabBarController?.popupPresentationState != .hidden
            {
                return
            }
            let audioSession = AVAudioSession.sharedInstance()
            try! audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try! audioSession.setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
            self.popupContentController = self.tabBarController?.storyboard?.instantiateViewController(withIdentifier: YSPlayerController.nameOfClass) as? YSPlayerController
            self.popupContentController?.viewModel = self.viewModel
            self.tabBarController?.presentPopupBar(withContentViewController: self.popupContentController!, animated: true, completion: nil)
            self.tabBarController?.popupBar?.tintColor = UIColor(white: 38.0 / 255.0, alpha: 1.0)
        }
    }
}
