//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Ioannis Tornazakis on 8/12/14.
//  Copyright (c) 2014 Ioannis Tornazakis. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    // MARK: Attributes
    
    // Audio players and engines
    var audioPlayer:AVAudioPlayer!
    var audioPlayerEcho:AVAudioPlayer!
    var audioEngine:AVAudioEngine!
    
    // Audio data
    var audioFile:AVAudioFile!
    var receivedAudio:RecordedAudio!
    
    // Audio parameters
    var normalRate:Float    = 1.0
    var slowRate:Float      = 0.5
    var fastRate:Float      = 1.5
    var normalVolume:Float  = 1.0
    var lowVolume:Float     = 0.3
    var noDelay:NSTimeInterval      = 0.0
    var smallDelay:NSTimeInterval   = 1.0
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Audio player
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error:nil)
        audioPlayer.enableRate = true
        
        // Audio player echo (Used for the echo effect only)
        audioPlayerEcho = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error:nil)
        audioPlayerEcho.enableRate = true
        
        // Audio Engine
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
        // Ensure the audio is played with proper volume on a real device
        let session = AVAudioSession.sharedInstance()
        var error: NSError?
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
        session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: &error)
        session.setActive(true, error: &error)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func playSlowAudio(sender: UIButton) {
        stopAllAudio()
        prepareAudio(audioPlayer, rate: slowRate, volume: normalVolume, delay: noDelay)
        audioPlayer.play()
        println("> Slow audio effect")
    }

    @IBAction func playFastAudio(sender: UIButton) {
        stopAllAudio()
        prepareAudio(audioPlayer, rate: fastRate, volume: normalVolume, delay: noDelay)
        audioPlayer.play()
        println("> Fast audio effect")
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        stopAllAudio()
        playAudioWithVariablePitch(1000)
        println("> Chipmunk audio effect")
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        stopAllAudio()
        playAudioWithVariablePitch(-1000)
        println("> Darth Vader audio effect")
    }
    
    
    /**
        playEchoAudio()

        Description:
        -   Echo is implemented by the use of two players, one
            on top of the other
        -   The first player just plays the original recording
        -   The second player plays the original recording 
            but with a small time delay and in lower volume
    */
    @IBAction func playEchoAudio(sender: UIButton) {
        stopAllAudio()
        prepareAudio(audioPlayer, rate: normalRate, volume: normalVolume, delay: noDelay)
        prepareAudio(audioPlayerEcho, rate: normalRate, volume: lowVolume, delay: smallDelay)
        audioPlayer.play()
        audioPlayerEcho.play()
        println("> Echo audio effect")
    }
    
    @IBAction func stopPlayingAudio(sender: UIButton) {
        stopAllAudio()
        println("> Stop audio")
    }
    
    // MARK: Utilities
    
    /**
        prepareAudio()

        Description:
        - Prepares the provided audio player with basic
          audio parameters:
        - rate
        - volume
        - delay
    */
    func prepareAudio(audioPlayer: AVAudioPlayer, rate: Float, volume: Float, delay: NSTimeInterval) {
        audioPlayer.currentTime = 0.0
        var delayNormalized = (audioPlayer.deviceCurrentTime + delay)
        audioPlayer.playAtTime(delayNormalized)
        audioPlayer.volume = volume
        audioPlayer.rate = rate
    }
    
    /**
        playAudioWithVariablePitch()

        Description:
        - Prepares the audio player to be able to handle
          the pitch
    */
    func playAudioWithVariablePitch(pitch: Float){
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    /**
        stopAllAudio()

        Description:
        -   Stops all audio players and audio engines.
        -   Needs to be called from within all action methods
          that invoke a player before using the player in
          order to avoid playing one player on top of the
          other incidentaly
    */
    func stopAllAudio() {
        audioPlayer.stop()
        audioPlayerEcho.stop()
        audioEngine.stop()
        audioEngine.reset()
    }

}
