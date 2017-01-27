//
//  PlayAudioViewController.swift
//  Name Your Key
//
//  Created by Paul Crompton on 1/23/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit
import AVFoundation

class PlayAudioViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var currentTransposition: Int = 0
    var currentPlayState: PlayingState = .notPlaying

    var stopTimer: Timer?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    enum PlayingState { case playing, notPlaying }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.selectRow(6, inComponent: 0, animated: false)
        setupAudio()
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        switch currentPlayState {
        case .playing:
            stopAudio()
        case .notPlaying:
            playAudio()
        }
        updatePlayButtonTitle(playState: currentPlayState)
    }
    
    // MARK: Main
    
    func setupAudio() {
        audioEngine = AVAudioEngine()
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL)
        } catch {
            print(error)
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        } catch {
            print("Could not set AVAudionSession category to .DefaultToSpeaker")
        }

    }
    
    func playAudio() {
        currentPlayState = .playing
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = Float(100*currentTransposition) + 1.0
        audioEngine.attach(changePitchEffect)
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format:  nil)
        
        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
            }
            
            // schedule a stop timer for when audio finishes playing
            if self.currentPlayState == .playing {
                self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlayAudioViewController.stopAudio), userInfo: nil, repeats: false)
                RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
            }
        }
        
        do {
            try audioEngine.start()
        } catch {
            print(error)
            return
        }
        
        // play the recording!
        audioPlayerNode.play()
    }
    
    func stopAudio() {
        
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        updatePlayButtonTitle(playState: .notPlaying)
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        currentPlayState = .notPlaying
    }
    
    // MARK: Helpers
    
    func updatePlayButtonTitle(playState: PlayingState) {
        switch playState {
        case .playing:
            playButton.setTitle("Stop", for: .normal)
        case .notPlaying:
            playButton.setTitle("Play", for: .normal)
        }
    }
    
    // MARK: UIPickerViewDataSource methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 13
    }
    
    // MARK: UIPickerViewDelegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row-6)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTransposition = row-6
    }
}
