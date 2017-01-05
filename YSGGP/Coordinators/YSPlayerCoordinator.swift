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
    func start() { }
    
    private var viewModel = YSPlayerViewModel()
    
    func start(tabBarController: UITabBarController)
    {
        let popupContentController = tabBarController.storyboard?.instantiateViewController(withIdentifier: YSPlayerController.nameOfClass) as! YSPlayerController
        let model = YSPlayerModel()
        viewModel.model = model
        popupContentController.viewModel = viewModel
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSessionCategoryPlayback)
        try! audioSession.setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        tabBarController.presentPopupBar(withContentViewController: popupContentController, animated: true, completion: nil)
        tabBarController.popupBar?.tintColor = UIColor(white: 38.0 / 255.0, alpha: 1.0)
    }
    
    func play(file: YSDriveFileProtocol)
    {
        viewModel.play(file: file)
    }
}
