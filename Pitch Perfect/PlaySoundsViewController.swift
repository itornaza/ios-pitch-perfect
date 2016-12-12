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
    
    // MARK: - Properties
    
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
    var noDelay:TimeInterval      = 0.0
    var smallDelay:TimeInterval   = 1.0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Audio player
        audioPlayer = try? AVAudioPlayer(contentsOf: receivedAudio.filePathUrl as URL)
        audioPlayer.enableRate = true
        
        // Audio player echo (Used for the echo effect only)
        audioPlayerEcho = try? AVAudioPlayer(contentsOf: receivedAudio.filePathUrl as URL)
        audioPlayerEcho.enableRate = true
        
        // Audio Engine
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl as URL)
        
        // Ensure the audio is played with proper volume on a real device
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error1 as NSError {
            let _ = error1
        }
        do {
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch let error1 as NSError {
            let _ = error1
        }
        do {
            try session.setActive(true)
        } catch let error1 as NSError {
            let _ = error1
        }
    }
    
    // MARK: - Actions
    
    @IBAction func playSlowAudio(_ sender: UIButton) {
        stopAllAudio()
        prepareAudio(audioPlayer, rate: slowRate, volume: normalVolume, delay: noDelay)
        audioPlayer.play()
    }

    @IBAction func playFastAudio(_ sender: UIButton) {
        stopAllAudio()
        prepareAudio(audioPlayer, rate: fastRate, volume: normalVolume, delay: noDelay)
        audioPlayer.play()
    }
    
    @IBAction func playChipmunkAudio(_ sender: UIButton) {
        stopAllAudio()
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVaderAudio(_ sender: UIButton) {
        stopAllAudio()
        playAudioWithVariablePitch(-1000)
    }
    
    /**
        -   Echo is implemented by the use of two players, one
            on top of the other
        -   The first player just plays the original recording
        -   The second player plays the original recording 
            but with a small time delay and in lower volume
    */
    @IBAction func playEchoAudio(_ sender: UIButton) {
        stopAllAudio()
        prepareAudio(audioPlayer, rate: normalRate, volume: normalVolume, delay: noDelay)
        prepareAudio(audioPlayerEcho, rate: normalRate, volume: lowVolume, delay: smallDelay)
        audioPlayer.play()
        audioPlayerEcho.play()
    }
    
    @IBAction func stopPlayingAudio(_ sender: UIButton) {
        stopAllAudio()
    }
    
    // MARK: - Helpers
    
    /**
        - Prepares the provided audio player with basic
          audio parameters:
        - rate
        - volume
        - delay
    */
    func prepareAudio(_ audioPlayer: AVAudioPlayer, rate: Float, volume: Float, delay: TimeInterval) {
        audioPlayer.currentTime = 0.0
        let delayNormalized = (audioPlayer.deviceCurrentTime + delay)
        audioPlayer.play(atTime: delayNormalized)
        audioPlayer.volume = volume
        audioPlayer.rate = rate
    }
    
    /**
        Prepares the audio player to be able to handle the pitch
    */
    func playAudioWithVariablePitch(_ pitch: Float){
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attach(changePitchEffect)
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch _ {
        }
        audioPlayerNode.play()
    }
    
    /**
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
