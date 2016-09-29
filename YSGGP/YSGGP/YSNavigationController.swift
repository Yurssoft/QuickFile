//
//  YSNavigationController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 9/29/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

class YSNavigationController: UINavigationController
{
    override func viewDidLoad()
    {
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss(animated:completion:)))
        navigationItem.setLeftBarButtonItems([leftButton], animated: true)
    }
}
