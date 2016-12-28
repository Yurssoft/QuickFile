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

class YSPlayerCoordinator: YSCoordinatorProtocol
{
    func start() { }
    
    func start(tabBarController: UITabBarController, firstFile: YSDriveFileProtocol)
    {
        let popupContentController = tabBarController.storyboard?.instantiateViewController(withIdentifier: YSPlayerController.nameOfClass) as! YSPlayerController
        let model = YSPlayerModel()
        let viewModel = YSPlayerViewModel()
        viewModel.model = model
        popupContentController.viewModel = viewModel
        
        tabBarController.presentPopupBar(withContentViewController: popupContentController, animated: true, completion: nil)
        tabBarController.popupBar?.tintColor = UIColor(white: 38.0 / 255.0, alpha: 1.0)
    }
}
