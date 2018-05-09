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

class YSPlayerController: UIViewController {
	@IBOutlet weak var songNameLabel: MarqueeLabel!
	@IBOutlet weak var albumNameLabel: UILabel!
	@IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var payPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var songSeekSlider: UISlider!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var volumeView: MPVolumeView!
    
    required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        updateBarButtons()
	}

    var viewModel: YSPlayerViewModelProtocol? {
        willSet {
            viewModel?.viewDelegate = nil
        }
        didSet {
            viewModel?.viewDelegate = self
        }
    }

    @IBAction func songSeekSliderValueChanged(_ sender: UISlider) {
        viewModel?.seekFloat(to: sender.value)
    }

    @IBAction func forward15SecondsTapped(_ sender: UIButton) {
        logPlayerSubdomain(.Controller, .Info, "")
        viewModel?.next()
    }

    @IBAction func backwards15SecondsTapped(_ sender: UIButton) {
        logPlayerSubdomain(.Controller, .Info, "")
        viewModel?.previous()
    }

    @IBAction func playPauseTapped(_ sender: UIButton) {
        logPlayerSubdomain(.Controller, .Info, "")
        viewModel?.togglePlayPause()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        volumeView.setRouteButtonImage(UIImage(named: "airplay"), for: UIControlState.normal)
        playerDidChange(viewModel: viewModel!)
    }
    func updateBarButtons() {
        guard let viewModel = viewModel  else {
            return
        }
        let pause = UIBarButtonItem(image: viewModel.isPlaying ? #imageLiteral(resourceName: "pause") : #imageLiteral(resourceName: "play"), style: .plain, target: self, action: #selector(playPauseTapped(_:)))
        let next = UIBarButtonItem(image: #imageLiteral(resourceName: "15_seconds_forward"), style: .plain, target: self, action: #selector(forward15SecondsTapped(_:)))

        popupItem.leftBarButtonItems = [ pause ]
        popupItem.rightBarButtonItems = [ next ]
    }

    func updateTime() {
        updateTimeLabels()
        updateSongSlider()
    }

    func updateTimeLabels() {
        guard let viewModel = viewModel else { return }
        elapsedTimeLabel.text = humanReadableTimeInterval(viewModel.fileCurrentTime)
        remainingTimeLabel.text = "-" + humanReadableTimeInterval(viewModel.fileDuration - viewModel.fileCurrentTime)
    }

    func updateSongSlider() {
        if songSeekSlider.isTracking {
            return
        }
        let fileDuration = Float(viewModel?.fileDuration ?? 0)
        let currentTime = Float(viewModel?.fileCurrentTime ?? 0)
        songSeekSlider.minimumValue = 0
        songSeekSlider.maximumValue = fileDuration
        songSeekSlider.value = currentTime
        popupItem.progress = currentTime / fileDuration
    }

    func humanReadableTimeInterval(_ timeInterval: TimeInterval) -> String {
        let timeInt = Int(round(timeInterval))
        let (hh, mm, ss) = (timeInt / 3600, (timeInt % 3600) / 60, (timeInt % 3600) % 60)

        let hhString: String? = hh > 0 ? String(hh) : nil
        let mmString = (hh > 0 && mm < 10 ? "0" : "") + String(mm)
        let ssString = (ss < 10 ? "0" : "") + String(ss)

        return (hhString != nil ? (hhString! + ":") : "") + mmString + ":" + ssString
    }

    func updatePopubButtons() {
        updateBarButtons()
        guard let file = viewModel?.currentFile else { return }
        popupItem.title = file.name
        popupItem.subtitle = file.folder.folderName
    }
}

extension YSPlayerController: YSPlayerViewModelViewDelegate {
    func playerDidChange(viewModel: YSPlayerViewModelProtocol) {
        logPlayerSubdomain(.Controller, .Info, "")
        DispatchQueue.main.async {
            self.updatePopubButtons()
            if self.isViewLoaded, let file = viewModel.currentFile {
                self.updateTime()
                self.payPauseButton.setImage(UIImage.init(named: viewModel.isPlaying ? "nowPlaying_pause" : "nowPlaying_play"), for: .normal)
                self.songNameLabel.text = file.name + "  "
                self.albumNameLabel.text = file.folder.folderName
            }
        }
    }

    func timeDidChange(viewModel: YSPlayerViewModelProtocol) {
        DispatchQueue.main.async {
            if self.isViewLoaded {
                self.updateTime()
            }
        }
    }

    func errorDidChange(viewModel: YSPlayerViewModelProtocol, error: YSErrorProtocol) {

    }
}
