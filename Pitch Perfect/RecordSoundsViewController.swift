//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by David Kobilnyk on 5/9/15.
//  Copyright (c) 2015 David Kobilnyk. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: - IBOutlets

    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var recordingLabel: UILabel!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var resumeButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    
    // MARK: - Private properties
    
    private var audioRecorder: AVAudioRecorder!
    private var recordedAudio: RecordedAudio!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUIModeToInitial()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != "stopRecording") {
            return
        }
        if let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as? PlaySoundsViewController {
            playSoundsVC.receivedAudio = sender as? RecordedAudio
        }
    }

    // MARK: - UI Events

    @IBAction func touchUpRecordButton(sender: UIButton) {
        self.setUIModeToRecord()
        self.startRecording()
    }

    @IBAction func touchUpPauseButton(sender: UIButton) {
        self.setUIModeToPause()
        self.pauseRecording()
    }

    @IBAction func touchUpResumeButton(sender: UIButton) {
        self.setUIModeToRecord()
        self.resumeRecording()
    }

    @IBAction func touchUpStopButton(sender: UIButton) {
        self.setUIModeToInitial()
        self.stopRecording()
    }

    // MARK: - AVAudioRecorderDelegate

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (!flag) {
            self.recordingLabel.text = "Record Failed. Tap to Re-Attempt Record"
            println("Recording was not successful")
            return
        }

        self.recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
        self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
    }

    // MARK: - Audio Control
    
    func startRecording() {
        if let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as? String {
            let currentDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(currentDateTime)+".wav"

            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)
            
            let session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)

            audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } else {
            println("could not save audio because document directory was not found")
        }
    }

    func pauseRecording() {
        self.audioRecorder.pause()
    }

    func resumeRecording() {
        self.audioRecorder.record()
    }

    func stopRecording() {
        audioRecorder.stop()

        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }

    // MARK: - View Model

    func setUIModeToInitial() {
        self.recordButton.enabled = true
        self.recordingLabel.text = "Tap to Record"
        self.pauseButton.hidden = true
        self.resumeButton.hidden = true
        self.stopButton.hidden = true
    }

    func setUIModeToRecord() {
        self.recordButton.enabled = false
        self.recordingLabel.text = "Recording"
        self.pauseButton.hidden = false
        self.resumeButton.hidden = true
        self.stopButton.hidden = false
    }

    func setUIModeToPause() {
        self.recordButton.enabled = false
        self.recordingLabel.text = "Paused"
        self.pauseButton.hidden = true
        self.resumeButton.hidden = false
        self.stopButton.hidden = false
    }
}

