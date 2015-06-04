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
    
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var audioPlayer: AVAudioPlayer!
    var playerNode: AVAudioPlayerNode!
    var receivedAudio: RecordedAudio!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.audioPlayer = AVAudioPlayer(contentsOfURL: self.receivedAudio.filePathUrl, fileTypeHint: "wav", error: nil)
        self.audioPlayer.enableRate = true
        
        self.audioEngine = AVAudioEngine()
        self.audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        self.playerNode = AVAudioPlayerNode()
        self.audioEngine.attachNode(self.playerNode)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Events

    @IBAction func touchUpSlowButton(sender: AnyObject) {
        self.playAudio(0.5)
    }
    
    @IBAction func touchUpFastButton(sender: UIButton) {
        self.playAudio(2.0)
    }
    
    @IBAction func touchUpChipmunkButton(sender: UIButton) {
        self.playAudioWithVariablePitch(1000)
    }
    
    @IBAction func touchUpDarthVaderButton(sender: UIButton) {
        self.playAudioWithVariablePitch(-1000)
    }
    
    @IBAction func touchUpStopButton(sender: UIButton) {
        self.resetAudio()
    }
    
    // MARK: - Audio Controls
    
    func playAudio(rate: Float) {
        self.resetAudio()
        self.audioPlayer.rate = rate
        self.audioPlayer.play()
    }
    
    func playAudioWithVariablePitch(pitch: Float){
        self.resetAudio()
        
        var audioPlayerNode = AVAudioPlayerNode()
        self.audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        self.audioEngine.attachNode(changePitchEffect)
        
        self.audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        self.audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        self.audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }
    
    func resetAudio() {
        self.audioEngine.stop()
        self.audioEngine.reset()
        self.audioPlayer.stop()
        self.audioPlayer.currentTime = 0
    }
}
