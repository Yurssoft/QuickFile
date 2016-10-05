//
//  YSToolbarView.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/4/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

@IBDesignable class YSToolbarView: UIToolbar
{
    // Our custom view from the XIB file
    var toolbarView: UIView!
    
    // Outlets
    @IBOutlet weak var selectAllButton: UIBarButtonItem!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupXib()
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setupXib()
    }
    
    func setupXib()
    {
        toolbarView = Bundle.main.loadNibNamed(YSToolbarView.nameOfClass, owner: self, options: nil)?[0] as! UIView
        
        // use bounds not frame or it'll be offset
        toolbarView.frame = bounds
        // Make the view stretch with containing view
        toolbarView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing)
        addSubview(toolbarView)
    }
}
