//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by David Kobilnyk on 5/9/15.
//  Copyright (c) 2015 David Kobilnyk. All rights reserved.
//
//  Code concepts and portions adapted from Udacity course "Intro to iOS App Development with Swift"
//

import UIKit
import AVFoundation

final class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: - IBOutlets

    /** Tapped to start the recording, during which the button is disabled. */
    @IBOutlet private weak var recordButton: UIButton!
    /** Gives the user direction or clarification regarding the recording process. */
    @IBOutlet private weak var recordingLabel: UILabel!
    /** Visible when a recording is in process, during which it can be tapped to pause the recording. */
    @IBOutlet private weak var pauseButton: UIButton!
    /** Visible when a recording is paused, during which it can be tapped to resume with recording. */
    @IBOutlet private weak var resumeButton: UIButton!
    /**
     Visible when a recording is in process, during which it can be tapped to complete the recording
     and push the next screen for adding effects.
    */
    @IBOutlet private weak var stopButton: UIButton!
    
    // MARK: - Private properties

    /** An object from AVFoundation used for performing all of the recording operations. */
    private var audioRecorder: AVAudioRecorder?
    /** A simple object for passing audio information to the next screen for replay. */
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
            setUIModeToFailed()
            println("Recording was not successful")
            return
        }

        recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
        performSegueWithIdentifier("stopRecording", sender: recordedAudio)
    }

    // MARK: - Audio Control
    
    func startRecording() {
        if let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as? String {
            // Determine file name for audio recording
            let currentDateTime = NSDate()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.stringFromDate(currentDateTime)+".wav"

            // Determine file path
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURLWithPathComponents(pathArray)

            // Configure the audio session
            let session = AVAudioSession.sharedInstance()
            var error: NSError?
            if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error) {
                setUIModeToFailed()
                println("audio session configuration failed: \(error?.description)")
                return
            }

            // Perform recording
            audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: &error)
            if let error = error {
                setUIModeToFailed()
                println("error preparing audio recorder: \(error.description)")
                return
            }
            if let audioRecorder = self.audioRecorder {
                audioRecorder.delegate = self
                audioRecorder.meteringEnabled = true
                audioRecorder.prepareToRecord()
                audioRecorder.record()
            } else {
                setUIModeToFailed()
            }
        } else {
            setUIModeToFailed()
            println("could not save audio because document directory was not found")
        }
    }

    func pauseRecording() {
        audioRecorder?.pause()
    }

    func resumeRecording() {
        audioRecorder?.record()
    }

    func stopRecording() {
        audioRecorder?.stop()

        let audioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !audioSession.setActive(false, error: &error) {
            setUIModeToFailed()
            println("audio session deactivation failed: \(error?.description)")
        }
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

    func setUIModeToFailed() {
        recordButton.enabled = true
        recordingLabel.text = "Record Failed. Tap to Re-Attempt Record"
        pauseButton.hidden = true
        resumeButton.hidden = true
        stopButton.hidden = true
    }
}

