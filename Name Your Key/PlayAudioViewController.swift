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

    var recording: Recording!
    var audioFileURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var currentTransposition: Int = 0
    var currentPlayState: PlayingState = .notPlaying

    var stopTimer: Timer?
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var originalKeyLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    enum PlayingState { case playing, notPlaying }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.selectRow(6, inComponent: 0, animated: false)
        if let title = recording.title {
            self.title = title
            saveButton.isEnabled = false
        } else {
            self.title = "Untitled"
        }
        if let filename = recording.filename {
            do {
                audioFileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)
            } catch {
                fatalError("Could not get file path")
            }
        } else {
            audioFileURL = URL(fileURLWithPath: Constants.audioFileLocation)
        }
        originalKeyLabel.text = recording.key!
        setupAudio()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if recording.title == nil {
            Constants.stack.delete(objects: [recording])
        }
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        print("Button Pressed")
        switch currentPlayState {
        case .playing:
            stopAudio()
        case .notPlaying:
            playAudio()
        }
        updatePlayButtonTitle(playState: currentPlayState)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let titleAlertController = UIAlertController(title: "Name Your Recording", message: "Choose a name for your recording:" , preferredStyle: .alert)
        titleAlertController.addTextField(configurationHandler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (saveAction) in
            if let text = titleAlertController.textFields?[0].text {
                self.saveAudio(title: text)
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        titleAlertController.addAction(saveAction)
        titleAlertController.addAction(cancelAction)
        present(titleAlertController, animated: true, completion: nil)
    }
    
    // MARK: Main
    
    func setupAudio() {
        audioEngine = AVAudioEngine()

        do {
            audioFile = try AVAudioFile(forReading: audioFileURL)
        } catch {
            fatalError(error.localizedDescription)
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        } catch {
            print("Could not set AVAudionSession category to .defaultToSpeaker")
        }

    }
    
    func playAudio() {
        currentPlayState = .playing
        pickerView.isUserInteractionEnabled = false
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
                DispatchQueue.main.async {
                    RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
                }
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
        
        stopTimer?.invalidate()
    
        updatePlayButtonTitle(playState: .notPlaying)
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        currentPlayState = .notPlaying
        pickerView.isUserInteractionEnabled = true
        
    }
    
    func saveAudio(title: String) {
        recording.title = title
        recording.filename = "\(title).m4a"
        let stack = Constants.stack
        let fm = FileManager.default

        do {
            let srcURL = audioFile.url
            let dstURL = try fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(recording.filename!)
            try fm.copyItem(at: srcURL, to: dstURL)
            
            stack.save()
        } catch {
            print(error)
        }

    }
    
    // MARK: Helpers
    func verifyFileExists() -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: audioFileURL.absoluteString)
    }
    
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
        if (row-6) > 0 {
            return "+\(row-6)"
        }
        return "\(row-6)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTransposition = row-6
    }
}
