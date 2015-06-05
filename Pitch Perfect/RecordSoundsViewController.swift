//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by David Kobilnyk on 5/9/15.
//  Copyright (c) 2015 David Kobilnyk. All rights reserved.
//

import UIKit
import AVFoundation

final class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
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
        
        setUIModeToInitial()
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
        setUIModeToRecord()
        startRecording()
    }

    @IBAction func touchUpPauseButton(sender: UIButton) {
        setUIModeToPause()
        pauseRecording()
    }

    @IBAction func touchUpResumeButton(sender: UIButton) {
        setUIModeToRecord()
        resumeRecording()
    }

    @IBAction func touchUpStopButton(sender: UIButton) {
        setUIModeToInitial()
        stopRecording()
    }

    // MARK: - AVAudioRecorderDelegate

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (!flag) {
            recordingLabel.text = "Record Failed. Tap to Re-Attempt Record"
            println("Recording was not successful")
            return
        }

        recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
        performSegueWithIdentifier("stopRecording", sender: recordedAudio)
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
        audioRecorder.pause()
    }

    func resumeRecording() {
        audioRecorder.record()
    }

    func stopRecording() {
        audioRecorder.stop()

        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }

    // MARK: - View Model

    func setUIModeToInitial() {
        recordButton.enabled = true
        recordingLabel.text = "Tap to Record"
        pauseButton.hidden = true
        resumeButton.hidden = true
        stopButton.hidden = true
    }

    func setUIModeToRecord() {
        recordButton.enabled = false
        recordingLabel.text = "Recording"
        pauseButton.hidden = false
        resumeButton.hidden = true
        stopButton.hidden = false
    }

    func setUIModeToPause() {
        recordButton.enabled = false
        recordingLabel.text = "Paused"
        pauseButton.hidden = true
        resumeButton.hidden = false
        stopButton.hidden = false
    }
}

