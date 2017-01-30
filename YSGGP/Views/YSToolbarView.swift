//
//  YSToolbarView.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/4/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit

protocol YSToolbarViewDelegate : class
{
    func selectAllButtonTapped(toolbar: YSToolbarView)
    func downloadButtonTapped(toolbar: YSToolbarView)
    func deleteButtonTapped(toolbar: YSToolbarView)
}

@IBDesignable class YSToolbarView: UIToolbar
{
    var view: UIView!
    
    @IBOutlet weak var selectAllButton: UIBarButtonItem!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    weak var ysToolbarDelegate: YSToolbarViewDelegate?
    
    @IBInspectable var SelectAllButtonText: String?
    {
        get
        {
            return selectAllButton.title
        }
        set(text)
        {
            selectAllButton.title = text
        }
    }
    
    @IBInspectable var DownloadButtonImage: UIImage?
    {
        get
        {
            return downloadButton.image
        }
        set(image)
        {
            downloadButton.image = image
        }
    }
    
    @IBAction func selectAllTapped(_ sender: UIBarButtonItem)
    {
        ysToolbarDelegate?.selectAllButtonTapped(toolbar: self)
    }
    
    @IBAction func downloadTapped(_ sender: UIBarButtonItem)
    {
        ysToolbarDelegate?.downloadButtonTapped(toolbar: self)
    }
    
    @IBAction func deleteTapped(_ sender: UIBarButtonItem)
    {
        ysToolbarDelegate?.deleteButtonTapped(toolbar: self)
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup()
    {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: YSToolbarView.nameOfClass, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
