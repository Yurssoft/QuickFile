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
    @IBOutlet weak var payPauseButton: UIButton!
	
	required init?(coder aDecoder: NSCoder)
    {
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
    
    @IBAction func playPauseTapped(_ sender: UIButton)
    {
        viewModel?.playPause()
    }
}

extension YSPlayerController : YSPlayerViewModelViewDelegate
{
    func playerDidChange(viewModel: YSPlayerViewModelProtocol)
    {
        DispatchQueue.main.async
            {
                let file = viewModel.currentFile()
                self.popupItem.title = file.fileName
                self.popupItem.subtitle = file.folder
                if self.isViewLoaded
                {
                    self.payPauseButton.setImage(UIImage.init(named: viewModel.isPlaying ? "nowPlaying_pause" : "nowPlaying_play"), for: .normal)
                    let file = viewModel.currentFile()
                    self.songNameLabel.text = file.fileName
                    self.albumNameLabel.text = file.folder
                    self.albumArtImageView.image = UIImage()
                }
        }
    }
    
    func filesDidChange(viewModel: YSPlayerViewModelProtocol)
    {
        
    }
    
    func errorDidChange(viewModel: YSPlayerViewModelProtocol, error: YSErrorProtocol)
    {
        
    }
}
