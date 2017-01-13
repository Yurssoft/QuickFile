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
	@IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var payPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var songSeekSlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
	
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
    
    @IBAction func songSeekSliderValueChanged(_ sender: UISlider)
    {
        viewModel?.seek(to: sender.value)
    }
    @IBAction func nextTapped(_ sender: UIButton)
    {
        viewModel?.next()
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton)
    {
        viewModel?.togglePlayPause()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        playerDidChange(viewModel: viewModel!)
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
    
    func updateTime()
    {
        updateTimeLabels()
        updateSlider()
    }
    
    func updateTimeLabels()
    {
        self.elapsedTimeLabel.text = self.humanReadableTimeInterval(viewModel?.fileCurrentTime ?? 0)
        self.remainingTimeLabel.text = "-" + self.humanReadableTimeInterval((viewModel?.fileDuration ?? 0) - (viewModel?.fileCurrentTime ?? 0))
    }
    
    func updateSlider()
    {
        if songSeekSlider.isTracking
        {
            return
        }
        let fileDuration = Float(viewModel?.fileDuration ?? 0)
        let currentTime = Float(viewModel?.fileCurrentTime ?? 0)
        songSeekSlider.minimumValue = 0
        songSeekSlider.maximumValue = fileDuration
        songSeekSlider.value = currentTime
        popupItem.progress = currentTime / fileDuration
    }
    
    func humanReadableTimeInterval(_ timeInterval: TimeInterval) -> String
    {
        let timeInt = Int(round(timeInterval))
        let (hh, mm, ss) = (timeInt / 3600, (timeInt % 3600) / 60, (timeInt % 3600) % 60)
        
        let hhString: String? = hh > 0 ? String(hh) : nil
        let mmString = (hh > 0 && mm < 10 ? "0" : "") + String(mm)
        let ssString = (ss < 10 ? "0" : "") + String(ss)
        
        return (hhString != nil ? (hhString! + ":") : "") + mmString + ":" + ssString
    }
    
    func updatePopubButtons()
    {
        updateBarButtons()
        guard let file = viewModel?.currentFile else { return }
        popupItem.title = file.fileName
        popupItem.subtitle = file.folder.folderName
    }
}

extension YSPlayerController : YSPlayerViewModelViewDelegate
{
    func playerDidChange(viewModel: YSPlayerViewModelProtocol)
    {
        DispatchQueue.main.async
        {
            self.updatePopubButtons()
            if self.isViewLoaded, let file = viewModel.currentFile
            {
                self.updateTime()
                self.payPauseButton.setImage(UIImage.init(named: viewModel.isPlaying ? "nowPlaying_pause" : "nowPlaying_play"), for: .normal)
                self.songNameLabel.text = file.fileName
                self.albumNameLabel.text = file.folder.folderName
                self.albumArtImageView.image = UIImage()
            }
        }
    }
    
    func timeDidChange(viewModel: YSPlayerViewModelProtocol)
    {
        DispatchQueue.main.async
        {
            if self.isViewLoaded
            {
                self.updateTime()
            }
        }
    }
    
    func errorDidChange(viewModel: YSPlayerViewModelProtocol, error: YSErrorProtocol)
    {
        
    }
}
