//
//  YSToolbarView.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/4/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import CoreGraphics

protocol YSToolbarViewDelegate : class {
    func selectAllButtonTapped(toolbar: YSToolbarView)
    func downloadButtonTapped(toolbar: YSToolbarView)
    func deleteButtonTapped(toolbar: YSToolbarView)
}

@IBDesignable class YSToolbarView: UIView {
    var view: UIView!

    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    weak var ysToolbarDelegate: YSToolbarViewDelegate?

    @IBInspectable var selectAllButtonText: String? {
        get {
            return selectAllButton.titleLabel?.text
        }
        set(text) {
            selectAllButton.setTitle(text, for: .normal)
        }
    }

    @IBInspectable var downloadButtonImage: UIImage? {
        get {
            return downloadButton.imageView?.image
        }
        set(image) {
            downloadButton.setImage(image, for: .normal)
        }
    }

    @IBAction func selectAllTapped(_ sender: UIButton) {
        logDefault(.View, .Info, "")
        ysToolbarDelegate?.selectAllButtonTapped(toolbar: self)
    }

    @IBAction func downloadTapped(_ sender: UIButton) {
        logDefault(.View, .Info, "")
        ysToolbarDelegate?.downloadButtonTapped(toolbar: self)
    }

    @IBAction func deleteTapped(_ sender: UIButton) {
        logDefault(.View, .Info, "")
        ysToolbarDelegate?.deleteButtonTapped(toolbar: self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: YSToolbarView.nameOfClass, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else { return UIView() }
        return view
    }
}
