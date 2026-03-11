//
//  MotionPlayerViewController.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit
import Combine

class MotionPlayerViewController: UIViewController {
    private let settings = AppSettings.standard

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

    var characterCode = ""
    var skillCode = ""

    private var motionData: MotionPlaybackData?

    private var player: MotionPlayer?

    private var downloadSubscription: AnyCancellable?
    private var playSubscription: AnyCancellable?

    private let frameNumberFormat = IntegerFormatStyle<Int>.number
        .grouping(.never)
        .precision(.integerLength(3...))

    override func viewDidLoad() {
        super.viewDidLoad()

        playerLayer = MotionPlayerLayer(
            hitboxVisibilitySettings: settings.hitboxVisibility,
            hitboxColorSettings: settings.hitboxColors
        )
        playerLayer.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer)

        configureHitboxCheckboxes()

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
        dismiss(animated: true, completion: nil)
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
        currentFPS = min(max(currentFPS, 0), 60)
        fpsTextField.text = String(currentFPS)
        player?.currentFPS = currentFPS
    }

    @IBAction func playOrPause(_ sender: UIButton) {
        if player?.state == .playing {
            player?.pause()
            sender.setImage(UIImage(systemName: "play.circle"), for: .normal)
        } else {
            player?.play()
            sender.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        }
    }

    @IBAction func forwardButtonAction(_ sender: Any) {
        player?.forward()
    }

    @IBAction func backwardButtonAction(_ sender: Any) {
        player?.backward()
    }

    @IBAction func togglePlayer1PassiveHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player1PassiveVisible)
    }

    @IBAction func togglePlayer1OtherVulnerabilityHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player1OtherVulnerabilityVisible)
    }

    @IBAction func togglePlayer1ActiveHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player1ActiveVisible)
    }

    @IBAction func togglePlayer1ThrowHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player1ThrowVisible)
    }

    @IBAction func togglePlayer1ThrowableHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player1ThrowableVisible)
    }

    @IBAction func togglePlayer1PushHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player1PushVisible)
    }

    @IBAction func togglePlayer2PassiveHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player2PassiveVisible)
    }

    @IBAction func togglePlayer2OtherVulnerabilityHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player2OtherVulnerabilityVisible)
    }

    @IBAction func togglePlayer2ActiveHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player2ActiveVisible)
    }

    @IBAction func togglePlayer2ThrowHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player2ThrowVisible)
    }

    @IBAction func togglePlayer2ThrowableHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player2ThrowableVisible)
    }

    @IBAction func togglePlayer2PushHitboxes(_ checkbox: UIButton) {
        toggle(checkbox, visibility: \.player2PushVisible)
    }

    // MARK: - Playback

    private func prepareToDownload() {
        downloadProgressView.progress = 0

        progressControl.isUserInteractionEnabled = false

        Task {
            do {
                let downloader = MotionDownloader(characterCode: characterCode, skillCode: skillCode)
                let motionData = try await downloader.download()

                self.motionData = motionData

                currentFrameLabel.text = frameLabelText(for: 0)
                totalFrameLabel.text = frameLabelText(for: motionData.frameCount)
                progressControl.maximumValue = Float(motionData.frameCount - 1)
                downloadProgressView.isHidden = false

                downloadProgressView.isHidden = true
                progressControl.isUserInteractionEnabled = true
                prepareToPlay()
            } catch {
                handleDownloadFailure(error)
            }
        }
    }

    private func prepareToPlay() {
        guard let motionData else {
            return
        }

        let player = MotionPlayer(motionData: motionData, playbackSettings: settings.playback)
        playSubscription = player.objectWillChange.sink(receiveValue: { _ in
            let currentFrame = player.currentFrame
            self.playerLayer.motionFrame = motionData.frames[currentFrame]
            self.currentFrameLabel.text = self.frameLabelText(for: currentFrame)
            self.progressControl.value = Float(currentFrame)
        })
        self.player = player
        fpsTextField.text = String(player.currentFPS)
        playerLayer.motionFrame = motionData.frames[player.currentFrame]
    }

    private func configureHitboxCheckboxes() {
        let visibility = settings.hitboxVisibility
        let colors = settings.hitboxColors

        configureHitboxCheckbox(player1PassiveHitboxesCheckbox, isVisible: visibility.player1PassiveVisible, rgb: colors.passiveRGB)
        configureHitboxCheckbox(player1OtherVulnerabilityHitboxesCheckbox, isVisible: visibility.player1OtherVulnerabilityVisible, rgb: colors.otherVulnerabilityRGB)
        configureHitboxCheckbox(player1ActiveHitboxesCheckbox, isVisible: visibility.player1ActiveVisible, rgb: colors.activeRGB)
        configureHitboxCheckbox(player1ThrowHitboxesCheckbox, isVisible: visibility.player1ThrowVisible, rgb: colors.throwRGB)
        configureHitboxCheckbox(player1ThrowableHitboxesCheckbox, isVisible: visibility.player1ThrowableVisible, rgb: colors.throwableRGB)
        configureHitboxCheckbox(player1PushHitboxesCheckbox, isVisible: visibility.player1PushVisible, rgb: colors.pushRGB)

        configureHitboxCheckbox(player2PassiveHitboxesCheckbox, isVisible: visibility.player2PassiveVisible, rgb: colors.passiveRGB)
        configureHitboxCheckbox(player2OtherVulnerabilityHitboxesCheckbox, isVisible: visibility.player2OtherVulnerabilityVisible, rgb: colors.otherVulnerabilityRGB)
        configureHitboxCheckbox(player2ActiveHitboxesCheckbox, isVisible: visibility.player2ActiveVisible, rgb: colors.activeRGB)
        configureHitboxCheckbox(player2ThrowHitboxesCheckbox, isVisible: visibility.player2ThrowVisible, rgb: colors.throwRGB)
        configureHitboxCheckbox(player2ThrowableHitboxesCheckbox, isVisible: visibility.player2ThrowableVisible, rgb: colors.throwableRGB)
        configureHitboxCheckbox(player2PushHitboxesCheckbox, isVisible: visibility.player2PushVisible, rgb: colors.pushRGB)
    }

    private func configureHitboxCheckbox(_ checkbox: UIButton, isVisible: Bool, rgb: Int) {
        checkbox.isSelected = isVisible
        checkbox.tintColor = UIColor(rgb: rgb, alpha: 1)
    }

    private func toggle(
        _ checkbox: UIButton,
        visibility: ReferenceWritableKeyPath<HitboxVisibilitySettings, Bool>
    ) {
        checkbox.isSelected.toggle()
        checkbox.backgroundColor = checkbox.isSelected ? checkbox.tintColor : .clear
        settings.hitboxVisibility[keyPath: visibility] = checkbox.isSelected
        playerLayer.setNeedsDisplay()
    }

    private func frameLabelText(for frame: Int) -> String {
        frame.formatted(frameNumberFormat)
    }

    private func handleDownloadFailure(_ error: Error) {
        downloadProgressView.isHidden = true
        progressControl.isUserInteractionEnabled = false
        motionData = nil

        let alert = UIAlertController(
            title: "Unable to Load Motion",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension MotionPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
