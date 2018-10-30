//
//  SkillMotionPlayerViewController.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

enum SkillMotionPlaybackState {
    case stopped
    case playing
    case paused
    case interrupted
    case seekingForward
    case seekingBackward
}

@objc protocol SkillMotionPlayerViewControllerDelegate {
    @objc optional func skillMotionPlayerViewControllerWillDismiss(_ skillMotionPlayerViewController: SkillMotionPlayerViewController)
}

class SkillMotionPlayerViewController: UIViewController {
    @IBOutlet var downloadProgressView: UIProgressView!
    @IBOutlet var currentFrameLabel: UILabel!
    @IBOutlet var totalFrameLabel: UILabel!
    @IBOutlet var fpsTextField: UITextField!
    @IBOutlet var framesPlayer: SkillMotionPlayer!
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
    
    private(set) var playbackState: SkillMotionPlaybackState = .stopped
    private(set) var isPreparedToPlay = false
    private(set) var numberOfFrames = 0
    private(set) var currentFrame = 0
    private(set) var currentFramesPerSecond = 0
    
    private var playTimer: Timer?
    private var seekingForwardTimer: Timer?
    private var seekingBackwardTimer: Timer?
    
    private var frameImages = NSMutableDictionary()
    private var framesInfo = NSDictionary()
    
    private var observer: NSObjectProtocol!
    
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
        
        player1PassiveHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player1PassiveHitboxHiddenKey)
        player1OtherVulnerabilityHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player1OtherVulnerabilityHitboxHiddenKey)
        player1ActiveHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player1ActiveHitboxHiddenKey)
        player1ThrowHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player1ThrowHitboxHiddenKey)
        player1ThrowableHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player1ThrowableHitboxHiddenKey)
        player1PushHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player1PushHitboxHiddenKey)
        
        player2PassiveHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player2PassiveHitboxHiddenKey)
        player2OtherVulnerabilityHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player2OtherVulnerabilityHitboxHiddenKey)
        player2ActiveHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player2ActiveHitboxHiddenKey)
        player2ThrowHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player2ThrowHitboxHiddenKey)
        player2ThrowableHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player2ThrowableHitboxHiddenKey)
        player2PushHitboxesCheckbox.isSelected = UserDefaults.standard.bool(forKey: Player2PushHitboxHiddenKey)
        
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

        prepareToPlay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isPreparedToPlay {
            update()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isPreparedToPlay && playbackState == .playing {
            play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        playTimer?.invalidate()
        playTimer = nil
    }
    
    // MARK: - Action
    
    @IBAction func dismiss(_ sender: Any) {
        delegate?.skillMotionPlayerViewControllerWillDismiss?(self)
        
        dismiss(animated: true) { [unowned self] in
            DownloadManager.shared.delegate = nil
            DownloadManager.sharedQueue.cancelAllOperations()
            self.playTimer?.invalidate()
            self.seekingForwardTimer?.invalidate()
            self.seekingBackwardTimer?.invalidate()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    @IBAction func progressControlDown(_ sender: Any) {
        playTimer?.invalidate()
        playTimer = nil
    }
    
    @IBAction func progressControlUp(_ sender: Any) {
        if playbackState == .playing {
            play()
        }
    }
    
    @IBAction func progressControlSlided(_ sender: Any) {
        currentFrame = Int(progressControl.value)
        update()
    }
    
    @IBAction func fpsChanged(_ sender: Any) {
        currentFramesPerSecond = fpsTextField.text.flatMap { Int($0) } ?? 0
        currentFramesPerSecond = max(currentFramesPerSecond, 0)
        currentFramesPerSecond = min(currentFramesPerSecond, 60)
        
        UserDefaults.standard.set(currentFramesPerSecond, forKey: PreferredFramesPerSecondKey)
        fpsTextField.text = String(currentFramesPerSecond)
        
        if playbackState == .playing {
            playTimer?.invalidate()
            playTimer = Timer.scheduledTimer(withTimeInterval: 1 / Double(currentFramesPerSecond), repeats: true) { [unowned self] _ in
                self.currentFrame = (self.currentFrame + 1) % self.numberOfFrames
                self.update()
            }
        }
    }
    
    @IBAction func playOrPause(_ sender: Any) {
        if playbackState == .playing {
            pause()
        } else {
            play()
        }
    }
    
    @IBAction func seekingForwardButtonTouchDown(_ sender: Any) {
        beginSeekingForward()
    }
    
    @IBAction func seekingForwardButtonTouchUp(_ sender: Any) {
        endSeeking()
    }
    
    @IBAction func seekingBackwardButtonTouchDown(_ sender: Any) {
        beginSeekingBackward()
    }
    
    @IBAction func seekingBackwardButtonTouchUp(_ sender: Any) {
        endSeeking()
    }
    
    @IBAction func togglePlayer1PassiveHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player1PassiveHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1OtherVulnerabilityHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player1OtherVulnerabilityHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1ActiveHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player1ActiveHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1ThrowHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player1ThrowHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1ThrowableHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player1ThrowableHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer1PushHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player1PushHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2PassiveHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player2PassiveHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2OtherVulnerabilityHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player2OtherVulnerabilityHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2ActiveHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player2ActiveHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2ThrowHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player2ThrowHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2ThrowableHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player2ThrowableHitboxHiddenKey)
    }
    
    @IBAction func togglePlayer2PushHitboxes(_ checkbox: UIButton) {
        checkbox.isSelected = !checkbox.isSelected
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        UserDefaults.standard.set(checkbox.isSelected, forKey: Player2PushHitboxHiddenKey)
    }
    
    // MARK: - Update
    
    func update() {
        let key = String(format: "motions/%@/%@/%@_%@_%03d.png", characterCode, skillCode, characterCode, skillCode, currentFrame)
        let frameImage = frameImages[key] as? UIImage
        let frameInfo = framesInfo[String(format: "%03d", currentFrame)] as! NSDictionary
        
        framesPlayer.drawFrameImage(frameImage, withFrameInfo: frameInfo)
        currentFrameLabel.text = String(format: "%03d", currentFrame)
        totalFrameLabel.text = String(format: "%03d", numberOfFrames - 1)
        progressControl.value = Float(currentFrame)
    }
    
    // MARK: - Playback
    
    func prepareToPlay() {
        isPreparedToPlay = false
        
        downloadProgressView.progress = 0
        
        currentFrame = 0
        currentFramesPerSecond = UserDefaults.standard.integer(forKey: PreferredFramesPerSecondKey)
        fpsTextField.text = String(currentFramesPerSecond)
        
        progressControl.isUserInteractionEnabled = false
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DownloadManager.shared.delegate = self
        
        let jsonFilePath = String(format: "motions/%@/%@/%@_%@.json", characterCode, skillCode, characterCode, skillCode)
        DownloadManager.shared.downloadJSONObjectWithFileAtRelativePath(jsonFilePath)
    }
    
    func play() {
        if isPreparedToPlay {
            playbackState = .playing
            
            currentFrame = (currentFrame + 1) % numberOfFrames
            update()
            
            if playTimer == nil {
                playTimer = Timer.scheduledTimer(withTimeInterval: 1 / Double(currentFramesPerSecond), repeats: true) { [unowned self] _ in
                    self.currentFrame = (self.currentFrame + 1) % self.numberOfFrames
                    self.update()
                }
            }
        }
    }
    
    func pause() {
        if isPreparedToPlay {
            playbackState = .paused
            
            playTimer?.invalidate()
            playTimer = nil
        }
    }
    
    func stop() {
        if isPreparedToPlay {
            playbackState = .stopped
            
            playTimer?.invalidate()
            playTimer = nil
            
            currentFrame = 0
        }
    }
    
    func beginSeekingForward() {
        if isPreparedToPlay {
            playbackState = .seekingForward
            
            playTimer?.invalidate()
            playTimer = nil
            
            currentFrame = (currentFrame + 1) % numberOfFrames
            update()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [unowned self] in
                if self.playbackState == .seekingForward {
                    self.currentFrame = (self.currentFrame + 1) % self.numberOfFrames
                    self.update()
                    
                    if self.seekingForwardTimer == nil {
                        self.seekingForwardTimer = Timer.scheduledTimer(withTimeInterval: 1 / Double(self.currentFramesPerSecond), repeats: true) { _ in
                            self.currentFrame = (self.currentFrame + 1) % self.numberOfFrames
                            self.update()
                        }
                    }
                }
            }
        }
    }
    
    func beginSeekingBackward() {
        if isPreparedToPlay {
            playbackState = .seekingBackward
            
            playTimer?.invalidate()
            playTimer = nil
            
            currentFrame = (currentFrame - 1 + numberOfFrames) % numberOfFrames
            update()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [unowned self] in
                if self.playbackState == .seekingBackward {
                    self.currentFrame = (self.currentFrame - 1 + self.numberOfFrames) % self.numberOfFrames
                    self.update()
                    
                    if self.seekingBackwardTimer == nil {
                        self.seekingBackwardTimer = Timer.scheduledTimer(withTimeInterval: 1 / Double(self.currentFramesPerSecond), repeats: true) { _ in
                            self.currentFrame = (self.currentFrame - 1 + self.numberOfFrames) % self.numberOfFrames
                            self.update()
                        }
                    }
                }
            }
        }
    }
    
    func endSeeking() {
        if isPreparedToPlay {
            playbackState = .paused
            
            seekingForwardTimer?.invalidate()
            seekingForwardTimer = nil
            
            seekingBackwardTimer?.invalidate()
            seekingBackwardTimer = nil
        }
    }
}

extension SkillMotionPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension SkillMotionPlayerViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        update()
    }
}

extension SkillMotionPlayerViewController: DownloadManagerDelegate {
    func downloadManager(_ downloadManager: DownloadManager, didFinishDownloadingJSONObject jsonObject: Any, atRelativePath relativePath: String) {
        framesInfo = jsonObject as! NSDictionary
        numberOfFrames = framesInfo.count
        
        currentFrameLabel.text = "000"
        totalFrameLabel.text = String(format: "%03d", numberOfFrames - 1)
        progressControl.maximumValue = Float(numberOfFrames - 1)
        
        for i in 0..<numberOfFrames {
            let imageFilePath = String(format: "motions/%@/%@/%@_%@_%03d.png", characterCode, skillCode, characterCode, skillCode, i)
            downloadManager.downloadImageWithFileAtRelativePath(imageFilePath)
        }
    }
    
    func downloadManager(_ downloadManager: DownloadManager, didFailToDownloadJSONObjectAtRelativePath relativePath: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let alert = UIAlertController(title: "无法连接到服务器", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [unowned self] action in
            self.dismiss(action)
        }))
        alert.addAction(UIAlertAction(title: "重试", style: .default, handler: { [unowned self] _ in
            self.prepareToPlay()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func downloadManager(_ downloadManager: DownloadManager, didFinishDownloadingImage image: UIImage, atRelativePath relativePath: String) {
        frameImages[relativePath] = image
        let numberOfImagesDownloaded = frameImages.count
        
        downloadProgressView.setProgress(Float(numberOfImagesDownloaded) / Float(numberOfFrames), animated: true)
        
        if numberOfImagesDownloaded == numberOfFrames {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            downloadProgressView.isHidden = true
            
            progressControl.isUserInteractionEnabled = true
            
            update()
            
            isPreparedToPlay = true
        }
    }
    
    func downloadManager(_ downloadManager: DownloadManager, didFailToDownloadImageAtRelativePath relativePath: String) {
        frameImages[relativePath] = NSNull()
        let numberOfImagesDownloaded = frameImages.count
        
        downloadProgressView.setProgress(Float(numberOfImagesDownloaded) / Float(numberOfFrames), animated: true)
        
        if numberOfImagesDownloaded == numberOfFrames {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            downloadProgressView.isHidden = true
            
            progressControl.isUserInteractionEnabled = true
            
            update()
            
            isPreparedToPlay = true
        }
    }
}
