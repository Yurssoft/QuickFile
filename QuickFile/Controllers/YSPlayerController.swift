//
//  YSDriveTopViewController.swift
//  YSGGP
//
//  Created by Yurii Boiko on 10/4/16.
//  Copyright © 2016 Yurii Boiko. All rights reserved.
//

import UIKit
import AVFoundation
import MarqueeLabel
import MediaPlayer
import SwiftyBeaver

class YSPlayerController: UIViewController
{
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
        viewModel?.seekFloat(to: sender.value)
    }
    
    @IBAction func volumeSliderValueChanged(_ sender: UISlider)
    {
        let volumeView = MPVolumeView()
        if let view = volumeView.subviews.first as? UISlider
        {
            view.value = sender.value
        }
    }
    
    @IBAction func nextTapped(_ sender: UIButton)
    {
        viewModel?.next()
    }
    
    @IBAction func previousTapped(_ sender: UIButton)
    {
        viewModel?.previous()
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton)
    {
        viewModel?.togglePlayPause()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        playerDidChange(viewModel: viewModel!)
        let log = SwiftyBeaver.self
        log.info("")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        let log = SwiftyBeaver.self
        log.info("")
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        let log = SwiftyBeaver.self
        log.info("")
    }
    
    func updateBarButtons()
    {
        guard let viewModel = viewModel  else {
            return
        }
        let pause = UIBarButtonItem(image: UIImage(named: viewModel.isPlaying ? "pause" : "play"), style: .plain, target: self, action: #selector(playPauseTapped(_:)))
        let next = UIBarButtonItem(image: UIImage(named: "nextFwd"), style: .plain, target: self, action: #selector(nextTapped(_:)))
        
        popupItem.leftBarButtonItems = [ pause ]
        popupItem.rightBarButtonItems = [ next ]
    }
    
    func updateTime()
    {
        updateTimeLabels()
        updateSongSlider()
        updateVolumeSlider()
    }
    
    func updateTimeLabels()
    {
        guard let viewModel = viewModel else { return }
        elapsedTimeLabel.text = humanReadableTimeInterval(viewModel.fileCurrentTime)
        remainingTimeLabel.text = "-" + humanReadableTimeInterval(viewModel.fileDuration - viewModel.fileCurrentTime)
    }
    
    func updateSongSlider()
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
    
    func updateVolumeSlider()
    {
        if volumeSlider.isTracking
        {
            return
        }
        volumeSlider.minimumValue = 0
        volumeSlider.maximumValue = 1
        let audioSession = AVAudioSession.sharedInstance()
        volumeSlider.value = audioSession.outputVolume
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
