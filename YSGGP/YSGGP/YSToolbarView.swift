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
    var toolbar: UIToolbar!
    
    // Outlets
    @IBOutlet weak var selectAllButton: UIBarButtonItem!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func setupXib()
    {
        toolbar = loadViewDromNib()
        
        // use bounds not frame or it'll be offset
        toolbar.frame = bounds
    }
    
    func loadViewDromNib() -> UIToolbar
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: YSToolbarView.nameOfClass, bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIToolbar
        return view
    }
}
