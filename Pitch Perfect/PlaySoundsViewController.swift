//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by David Kobilnyk on 5/16/15.
//  Copyright (c) 2015 David Kobilnyk. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    // MARK: - Properties

    // MARK: Public/Internal
    internal var receivedAudio: RecordedAudio?

    // MARK: Private
    private var audioEngine: AVAudioEngine?
    private var audioFile: AVAudioFile?
    private var audioPlayer: AVAudioPlayer?
    private var playerNode: AVAudioPlayerNode?
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let receivedAudio = self.receivedAudio {
            self.audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, fileTypeHint: "wav", error: nil)
            self.audioPlayer!.enableRate = true

            self.audioEngine = AVAudioEngine()
            self.audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
            self.playerNode = AVAudioPlayerNode()
            self.audioEngine!.attachNode(self.playerNode)
        } else {
            println("no audio received")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UI Events

    @IBAction func touchUpSlowButton(sender: AnyObject) {
        self.playAudio(rate: 0.5)
    }

    @IBAction func touchUpFastButton(sender: UIButton) {
        self.playAudio(rate: 2.0)
    }

    @IBAction func touchUpChipmunkButton(sender: UIButton) {
        self.playAudio(pitch: 1000)
    }

    @IBAction func touchUpDarthVaderButton(sender: UIButton) {
        self.playAudio(pitch: -1000)
    }

    @IBAction func touchUpStopButton(sender: UIButton) {
        self.resetAudio()
    }

    // MARK: - Audio Controls
    
    func playAudio(#rate: Float) {
        self.resetAudio()

        if let audioPlayer = self.audioPlayer {
            audioPlayer.rate = rate
            audioPlayer.play()
        } else {
            println("no audio to play")
        }
    }

    func playAudio(#pitch: Float){
        self.resetAudio()

        if let audioEngine = self.audioEngine {
            let audioPlayerNode = AVAudioPlayerNode()
            audioEngine.attachNode(audioPlayerNode)

            let changePitchEffect = AVAudioUnitTimePitch()
            changePitchEffect.pitch = pitch
            audioEngine.attachNode(changePitchEffect)

            audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
            audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)

            audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
            audioEngine.startAndReturnError(nil)

            audioPlayerNode.play()
        } else {
            println("no audio to play")
        }
    }

    func resetAudio() {
        if let audioEngine = self.audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        if let audioPlayer = self.audioPlayer {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
    }
}
