//
//  SkillMotionPlayerViewController.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit
import Combine

@objc protocol SkillMotionPlayerViewControllerDelegate {
    @objc optional func skillMotionPlayerViewControllerWillDismiss(_ skillMotionPlayerViewController: SkillMotionPlayerViewController)
}

class SkillMotionPlayerViewController: UIViewController {
    @IBOutlet var playerView: UIView!
    private var playerLayer: MotionPlayerLayer!
    
    @IBOutlet var downloadProgressView: UIProgressView!
    @IBOutlet var currentFrameLabel: UILabel!
    @IBOutlet var totalFrameLabel: UILabel!
    @IBOutlet var fpsTextField: UITextField!
    @IBOutlet var progressControl: UISlider!
    
    @IBOutlet var player1HitboxesView: UIView!
    @IBOutlet var player1PassiveHitboxesCheckbox: UIButton!
    @IBOutlet var player1OtherVulnerabilityHitboxesCheckbox: UIButton!
    @IBOutlet var player1ActiveHitboxesCheckbox: UIButton!
    @IBOutlet var player1ThrowHitboxesCheckbox: UIButton!
    @IBOutlet var player1ThrowableHitboxesCheckbox: UIButton!
    @IBOutlet var player1PushHitboxesCheckbox: UIButton!
    
    @IBOutlet var player2HitboxesView: UIView!
    @IBOutlet var player2PassiveHitboxesCheckbox: UIButton!
    @IBOutlet var player2OtherVulnerabilityHitboxesCheckbox: UIButton!
    @IBOutlet var player2ActiveHitboxesCheckbox: UIButton!
    @IBOutlet var player2ThrowHitboxesCheckbox: UIButton!
    @IBOutlet var player2ThrowableHitboxesCheckbox: UIButton!
    @IBOutlet var player2PushHitboxesCheckbox: UIButton!
    
    weak var delegate: SkillMotionPlayerViewControllerDelegate?
    var characterCode = ""
    var skillCode = ""
    
    private var observer: NSObjectProtocol!
    
    private var downloader: MotionDownloader?
    private var motionInfo: MotionInfo?
    
    private var player: MotionPlayer?
    
    private var downloadSubscription: AnyCancellable?
    private var playSubscription: AnyCancellable?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { _ in
            var backgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
            backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerLayer = MotionPlayerLayer()
        playerLayer.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer)
        
        player1PassiveHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player1PassiveHitboxHiddenKey)
        player1OtherVulnerabilityHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player1OtherVulnerabilityHitboxHiddenKey)
        player1ActiveHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player1ActiveHitboxHiddenKey)
        player1ThrowHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player1ThrowHitboxHiddenKey)
        player1ThrowableHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player1ThrowableHitboxHiddenKey)
        player1PushHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player1PushHitboxHiddenKey)
        
        player2PassiveHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player2PassiveHitboxHiddenKey)
        player2OtherVulnerabilityHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player2OtherVulnerabilityHitboxHiddenKey)
        player2ActiveHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player2ActiveHitboxHiddenKey)
        player2ThrowHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player2ThrowHitboxHiddenKey)
        player2ThrowableHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player2ThrowableHitboxHiddenKey)
        player2PushHitboxesCheckbox.isSelected = !UserDefaults.standard.bool(forKey: Player2PushHitboxHiddenKey)
        
        player1PassiveHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredPassiveHitboxRGBColorKey), alpha:1)
        player1OtherVulnerabilityHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredOtherVulnerabilityHitboxRGBColorKey), alpha:1)
        player1ActiveHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredActiveHitboxRGBColorKey), alpha:1)
        player1ThrowHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredThrowHitboxRGBColorKey), alpha:1)
        player1ThrowableHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredThrowableHitboxRGBColorKey), alpha:1)
        player1PushHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredPushHitboxRGBColorKey), alpha:1)
        
        player2PassiveHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredPassiveHitboxRGBColorKey), alpha:1)
        player2OtherVulnerabilityHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredOtherVulnerabilityHitboxRGBColorKey), alpha:1)
        player2ActiveHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredActiveHitboxRGBColorKey), alpha:1)
        player2ThrowHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredThrowHitboxRGBColorKey), alpha:1)
        player2ThrowableHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredThrowableHitboxRGBColorKey), alpha:1)
        player2PushHitboxesCheckbox.tintColor = UIColor(rgb: UserDefaults.standard.integer(forKey: PreferredPushHitboxRGBColorKey), alpha:1)
        
        let checkboxes: [UIButton] = [
            player1PassiveHitboxesCheckbox,
            player1OtherVulnerabilityHitboxesCheckbox,
            player1ActiveHitboxesCheckbox,
            player1ThrowHitboxesCheckbox,
            player1ThrowableHitboxesCheckbox,
            player1PushHitboxesCheckbox,
            player2PassiveHitboxesCheckbox,
            player2OtherVulnerabilityHitboxesCheckbox,
            player2ActiveHitboxesCheckbox,
            player2ThrowHitboxesCheckbox,
            player2ThrowableHitboxesCheckbox,
            player2PushHitboxesCheckbox
        ]
        
        for checkbox in checkboxes {
            checkbox.layer.shadowColor = checkbox.tintColor.cgColor
            checkbox.layer.shadowRadius = 5
            checkbox.layer.borderColor = checkbox.tintColor.cgColor
            checkbox.layer.borderWidth = 1
            checkbox.layer.cornerRadius = 3
            checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        }
        
        for view in [player1HitboxesView, player2HitboxesView] as [UIView] {
            view.layer.borderColor = UIColor.gray.cgColor
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 5
        }

        prepareToDownload()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        playerLayer.frame = playerView.bounds
    }
    
    // MARK: - Action
    
    @IBAction func dismiss(_ sender: Any) {
        delegate?.skillMotionPlayerViewControllerWillDismiss?(self)
    }
    
    @IBAction func progressControlDown(_ sender: Any) {
        player?.beginSeeking()
    }
    
    @IBAction func progressControlUp(_ sender: Any) {
        player?.endSeeking()
    }
    
    @IBAction func progressControlSlided(_ sender: Any) {
        let frame = Int(progressControl.value)
        player?.seek(to: frame)
    }
    
    @IBAction func fpsChanged(_ sender: Any) {
        var currentFPS = fpsTextField.text.flatMap { Int($0) } ?? 0
        currentFPS = max(currentFPS, 0)
        currentFPS = min(currentFPS, 60)
        fpsTextField.text = String(currentFPS)
        player?.currentFPS = currentFPS
    }
    
    @IBAction func playOrPause(_ sender: UIButton) {
        if player?.state == .playing {
            player?.pause()
            sender.setImage(UIImage(systemName: "play"), for: .normal)
        } else {
            player?.play()
            sender.setImage(UIImage(systemName: "pause"), for: .normal)
        }
    }
    
    @IBAction func forwardButtonAction(_ sender: Any) {
        player?.forward()
    }
    
    @IBAction func backwardButtonAction(_ sender: Any) {
        player?.backward()
    }
    
    @IBAction func togglePlayer1PassiveHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player1PassiveHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1OtherVulnerabilityHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player1OtherVulnerabilityHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1ActiveHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player1ActiveHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1ThrowHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player1ThrowHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1ThrowableHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player1ThrowableHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1PushHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player1PushHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2PassiveHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player2PassiveHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2OtherVulnerabilityHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player2OtherVulnerabilityHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2ActiveHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player2ActiveHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2ThrowHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player2ThrowHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2ThrowableHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player2ThrowableHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2PushHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(!checkbox.isSelected, forKey: Player2PushHitboxHiddenKey)
    }
    
    // MARK: - Playback
    
    private func prepareToDownload() {
        downloadProgressView.progress = 0
        
        progressControl.isUserInteractionEnabled = false
        
        let downloader = MotionDownloader(characterCode: characterCode, skillCode: skillCode)
        downloadSubscription = downloader.downloadPublisher().receive(on: RunLoop.main).sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                self.downloadProgressView.isHidden = true
                self.progressControl.isUserInteractionEnabled = true
                self.prepareToPlay()
            case .failure(let error):
                let alert = UIAlertController(title: "无法连接到服务器", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [unowned self] action in
                    self.dismiss(action)
                }))
                alert.addAction(UIAlertAction(title: "重试", style: .default, handler: { [unowned self] _ in
                    self.prepareToDownload()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }, receiveValue: { (value) in
            self.motionInfo = value.motionInfo
            
            self.currentFrameLabel.text = "000"
            self.totalFrameLabel.text = String(format: "%03d", value.motionInfo.frames.count)
            self.progressControl.maximumValue = Float(value.motionInfo.frames.count - 1)
            self.downloadProgressView.isHidden = false
            self.downloadProgressView.setProgress(Float(value.progress.fractionCompleted), animated: true)
        })
        self.downloader = downloader
    }
    
    private func prepareToPlay() {
        guard let motionInfo = motionInfo else {
            return
        }
        
        let player = MotionPlayer(motionInfo: motionInfo)
        playSubscription = player.objectWillChange.sink(receiveValue: { _ in
            let currentFrame = player.currentFrame
            self.playerLayer.motionFrame = motionInfo.frames[currentFrame]
            self.currentFrameLabel.text = String(format: "%03d", currentFrame)
            self.progressControl.value = Float(currentFrame)
        })
        self.player = player
    }
}

extension SkillMotionPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
