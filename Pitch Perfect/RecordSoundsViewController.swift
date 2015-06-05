//
//  ViewController.swift
//  Pitch Perfect
//
//  Created by Ioannis Tornazakis on 12/12/14.
//  Copyright (c) 2014 Ioannis Tornazakis. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // MARK: Attributes
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var pauseFlag:Bool!
    var firstTimeFlag:Bool!
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        // Buttons state
        recordButton.enabled = true
        
        // Display appropriate labels
        tapToRecord.hidden          = false
        recordingInProgress.hidden  = true
        tapToPause.hidden           = true
        tapToResume.hidden          = true
        stopButton.hidden           = true
        
        // Set up attributes
        pauseFlag       = false
        firstTimeFlag   = true
    }
    
    /**
        prepareForSegue()

        Description:
        -   Prepares the audio data that have been captured in order
          to be transfered by the upcomming segue
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            // Send the audio to the PlaySoundsViewController
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var tapToRecord: UILabel!
    @IBOutlet weak var tapToResume: UILabel!
    @IBOutlet weak var tapToPause: UILabel!

    /**
        recordingAudio()

        Description:
        -   This Action controls the recording states which are:
          -   Initiate recording
          -   Pause recording
          -   Resume recording

        -   In this way the microphone icon can be used to
          toggle between these states and appropriate messages
          inform the user what to do next by tapping the mic

        -   Note that the pauseFlag and the firstTimeFlag
          are defining the state transitions
    */
    @IBAction func recordingAudio(sender: UIButton) {
        // Initial recording state
        if ( pauseFlag == false && (firstTimeFlag == true) ) {
            initiateRecording()
            // Prepare flags for the pause state
            firstTimeFlag   = false
            pauseFlag       = true
            
            // Pause state
        } else if ( pauseFlag == true ) {
            pauseRecording()
            // prepare flags for the resume state
            pauseFlag = false
            
            // Resume state
        } else {
            resumeRecording()
            // Prepare flags for the pause state
            pauseFlag = true
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        audioRecorder.stop()
        
        // Display appropriate labels
        tapToRecord.hidden          = false
        recordingInProgress.hidden  = true
        tapToPause.hidden           = true
        tapToResume.hidden          = true
        stopButton.hidden           = true
        
        // Set up attributes
        pauseFlag       = false
        firstTimeFlag   = true
        
        // Close recording session
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        
        println("> Stop recording")
    }
    
    // MARK: Utilities
    
    /**
        initiateRecording()

        Description:
        -   Initializes the recorder with all necessary parameters
          and begins recording for the first time after the
          scene loads
        -   Sets up the file that the recording is stored
    */
    func initiateRecording() {
        // Buttons state
        recordButton.enabled = true
        
        // Display appropriate labels
        tapToRecord.hidden          = true
        recordingInProgress.hidden  = false
        tapToPause.hidden           = false
        tapToResume.hidden          = true
        stopButton.hidden           = false
        
        // Recording file (unique filename and path)
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        // Initiate recording session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        
        // Audio recorder and its parameters
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        
        // This class becomes a delegate of the AVAudioRecorderDelegate
        // and we now can use the function: audioRecorderDidFinishRecording
        // that is implemented in "Delegates" section below
        audioRecorder.delegate = self
        
        // Start recording
        audioRecorder.record()
        
        println("> Initiate recording")
    }
    
    /**
        pauseRecording()

        Description:
        -   Pauses the recording once it has already been initiated
    */
    func pauseRecording() {
        audioRecorder.pause()
        
        // Buttons state
        recordButton.enabled = true
        
        // Display appropriate labels
        recordingInProgress.hidden  = true
        tapToRecord.hidden          = true
        tapToPause.hidden           = true
        tapToResume.hidden          = false
        stopButton.hidden           = false
        
        //
        pauseFlag = false
        
        println("> Pause recording");
    }
    
    /**
        resumeRecording()

        Description:
        -   Resumes recording after it has been paused
    */
    func resumeRecording() {
        audioRecorder.record()
        
        // Buttons state
        recordButton.enabled = true
        
        // Display appropriate labels
        recordingInProgress.hidden  = false
        tapToRecord.hidden          = true
        tapToPause.hidden           = false
        tapToResume.hidden          = true
        stopButton.hidden           = false
        
        pauseFlag = true
        
        println("> Resume recording")
    }
    
    // MARK: Delegates
    
    /**
        audioRecorderDidFinishRecording()

        Description:
        -   Reference to AVAudioRecorderDelegate protocol
        -   Ensures that the segue from the recorder to the player
          is performed if and only if the recording was completed with
          success. Otherwise displays an error message
    */
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) { // if the recording was successful
            // Save the recorded audio through its constructor
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            
            // Move to the second scene, aka perform segue
            // just after we have finish recording
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
            
        } else {    // Handle error in recording
            // Buttons state
            recordButton.enabled = true
            
            // Display appropriate labels
            tapToRecord.hidden          = false
            recordingInProgress.hidden  = true
            tapToPause.hidden           = true
            tapToResume.hidden          = true
            stopButton.hidden           = true
            
            // Set up attributes
            pauseFlag       = false
            firstTimeFlag   = true
            
            println("> Recording was not successful")
        }
    }
}
