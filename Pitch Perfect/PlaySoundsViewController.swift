//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by David Kobilnyk on 5/16/15.
//  Copyright (c) 2015 David Kobilnyk. All rights reserved.
//

import UIKit
import AVFoundation

final class PlaySoundsViewController: UIViewController {

    // MARK: - Properties

    // MARK: Public/Internal
    /** This object contains audio file info which can be set by the calling class. */
    internal var receivedAudio: RecordedAudio?

    // MARK: Private
    /** Used for replaying an audio file with varied pitch. */
    private var audioEngine: AVAudioEngine?
    /** Used with audioEngine for playing audio with varied pitch. */
    private var audioFile: AVAudioFile?
    /** Used for replaying an audio file with varied speed. */
    private var audioPlayer: AVAudioPlayer?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if let receivedAudio = self.receivedAudio {
            var error: NSError?
            audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, fileTypeHint: "wav", error: &error)
            if let error = error {
                println("error initializing audio player: \(error.description)")
            } else {
                audioPlayer?.enableRate = true
            }

            audioEngine = AVAudioEngine()
            audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: &error)
            if let error = error {
                println("error accessing audio file: \(error.description)")
            }
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
        playAudio(rate: 0.5)
    }

    @IBAction func touchUpFastButton(sender: UIButton) {
        playAudio(rate: 2.0)
    }

    @IBAction func touchUpChipmunkButton(sender: UIButton) {
        playAudio(pitch: 1000)
    }

    @IBAction func touchUpDarthVaderButton(sender: UIButton) {
        playAudio(pitch: -1000)
    }

    @IBAction func touchUpStopButton(sender: UIButton) {
        resetAudio()
    }

    // MARK: - Audio Controls
    
    func playAudio(#rate: Float) {
        resetAudio()

        if let audioPlayer = audioPlayer {
            audioPlayer.rate = rate
            audioPlayer.play()
        } else {
            println("no audio to play")
        }
    }

    func playAudio(#pitch: Float){
        resetAudio()

        if let audioEngine = self.audioEngine {
            // Code adapted from http://stackoverflow.com/q/25333140/576101
            // Initialize audioEngine with our single audio node
            let audioPlayerNode = AVAudioPlayerNode()
            audioEngine.attachNode(audioPlayerNode)

            // Initialize audioEngine with a pitch modification effect
            let changePitchEffect = AVAudioUnitTimePitch()
            changePitchEffect.pitch = pitch
            audioEngine.attachNode(changePitchEffect)

            // Make connections between the various components to be used with audioEngine
            audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
            audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)

            // Play the audio
            audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
            var error: NSError?
            if audioEngine.startAndReturnError(&error) {
                audioPlayerNode.play()
            } else {
                println("audio failed to play: \(error?.description)")
            }
        } else {
            println("no audio to play")
        }
    }

    func resetAudio() {
        audioEngine?.stop()
        audioEngine?.reset()
        
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
    }
}
