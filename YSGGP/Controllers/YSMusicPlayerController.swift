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

class YSMusicPlayerController: UIViewController {

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
	
	var songTitle: String = "" {
		didSet {
			if isViewLoaded {
				songNameLabel.text = songTitle
			}
			popupItem.title = songTitle
		}
	}
	var albumTitle: String = "" {
		didSet {
			if isViewLoaded {
				albumNameLabel.text = albumTitle
			}
		}
	}
	var albumArt: UIImage = UIImage() {
		didSet {
			if isViewLoaded {
				albumArtImageView.image = albumArt
			}
			popupItem.image = albumArt
		}
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songNameLabel.text = songTitle
        albumNameLabel.text = albumTitle
        albumArtImageView.image = albumArt
    }
    
    func configure(files:[YSDriveFileProtocol], songTitle: String, albumTitle: String, albumArt: UIImage)
    {
        self.songTitle = songTitle
        self.albumTitle = albumTitle
        self.albumArt = albumArt
        var audioItems: [AVPlayerItem] = []
        for file in files {
            let item = AVPlayerItem(url: file.localFilePath()!)
            audioItems.append(item)
        }
        
        player = AVQueuePlayer(items: audioItems)
        player.play()
    }
    
}
