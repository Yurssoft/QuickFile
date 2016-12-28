//
//  DemoMusicPlayerController.swift
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

import UIKit
import LNPopupController
import AVFoundation

class YSPlayerController: UIViewController {

	@IBOutlet weak var songNameLabel: UILabel!
	@IBOutlet weak var albumNameLabel: UILabel!
	@IBOutlet weak var progressView: UIProgressView!
    var player: AVQueuePlayer = AVQueuePlayer(items: [])
	@IBOutlet weak var albumArtImageView: UIImageView!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		let pause = UIBarButtonItem(image: UIImage(named: "pause"), style: .plain, target: nil, action: nil)
		let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: nil, action: nil)
		
		self.popupItem.leftBarButtonItems = [ pause ]
		self.popupItem.rightBarButtonItems = [ next ]
	}
    
    var viewModel: YSPlayerViewModelProtocol?
    {
        willSet
        {
            viewModel?.viewDelegate = nil
        }
        didSet
        {
            viewModel?.viewDelegate = self
        }
    }
	var songTitle: String = ""
    {
		didSet
        {
			if isViewLoaded
            {
				songNameLabel.text = songTitle
			}
			popupItem.title = songTitle
		}
	}
	var albumTitle: String = ""
    {
		didSet
        {
			if isViewLoaded
            {
				albumNameLabel.text = albumTitle
			}
		}
	}
	var albumArt: UIImage = UIImage()
    {
		didSet
        {
			if isViewLoaded
            {
				albumArtImageView.image = albumArt
			}
			popupItem.image = albumArt
		}
	}
    
    @IBAction func playPauseTapped(_ sender: UIButton)
    {
        viewModel?.playPause()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        songNameLabel.text = songTitle
        albumNameLabel.text = albumTitle
        albumArtImageView.image = albumArt
    }
}

extension YSPlayerController : YSPlayerViewModelViewDelegate
{
    func progressDidChange(viewModel: YSPlayerViewModelProtocol)
    {
        
    }
    func filesDidChange(viewModel: YSPlayerViewModelProtocol)
    {
        
    }
    func errorDidChange(viewModel: YSPlayerViewModelProtocol, error: YSErrorProtocol)
    {
        
    }
}
