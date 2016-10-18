//
//  YSTabBarController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/28/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

extension UITabBarController
{
    func setTabBarVisible(isVisible : Bool, animated: Bool, completion: (() -> Swift.Void)? = nil)
    {
        let tabBarFrame = tabBar.frame
        let tabBarHeight = tabBarFrame.size.height
        let offsetY = (isVisible ? -tabBarHeight : tabBarHeight)
        
        let duration:TimeInterval = (animated ? 0.3 : 0.0)
        
        UIView.animate(withDuration: duration,
                       animations: {
                        [weak self] in self?.tabBar.frame = tabBarFrame.offsetBy(dx: 0, dy: offsetY)
            },
                       completion:{ (isFinished) in
                        if isFinished && completion != nil
                        {
                            completion!()
                        }
        })
    }
    
    func tabBarIsVisible() -> Bool
    {
        return tabBar.frame.origin.y < UIScreen.main.bounds.height
    }
}
