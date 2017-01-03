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
import MarqueeLabel

class YSPlayerController: UIViewController {

	@IBOutlet weak var songNameLabel: MarqueeLabel!
	@IBOutlet weak var albumNameLabel: UILabel!
	@IBOutlet weak var progressView: UIProgressView!
    var player: AVQueuePlayer = AVQueuePlayer(items: [])
	@IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var payPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
	
	required init?(coder aDecoder: NSCoder)
    {
		super.init(coder: aDecoder)
        updateBarButtons()
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
    
    @IBAction func nextTapped(_ sender: Any)
    {
        viewModel?.next()
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton)
    {
        viewModel?.playPause()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func updateBarButtons()
    {
        guard let viewModel = viewModel  else {
            return
        }
        let pause = UIBarButtonItem(image: UIImage(named: viewModel.isPlaying ? "pause" : "play"), style: .plain, target: self, action: #selector(playPauseTapped(_:)))
        let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: self, action: #selector(nextTapped(_:)))
        
        self.popupItem.leftBarButtonItems = [ pause ]
        self.popupItem.rightBarButtonItems = [ next ]
    }
}

extension YSPlayerController : YSPlayerViewModelViewDelegate
{
    func playerDidChange(viewModel: YSPlayerViewModelProtocol)
    {
        DispatchQueue.main.async
            {
                self.updateBarButtons()
                
                let file = viewModel.currentFile()
                self.popupItem.title = file.fileName
                self.popupItem.subtitle = file.folder.folderName
                if self.isViewLoaded
                {
                    self.payPauseButton.setImage(UIImage.init(named: viewModel.isPlaying ? "nowPlaying_pause" : "nowPlaying_play"), for: .normal)
                    let file = viewModel.currentFile()
                    self.songNameLabel.text = file.fileName
                    self.albumNameLabel.text = file.folder.folderName
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
