//
//  RecordViewController.swift
//  Name Your Key
//
//  Created by Paul Crompton on 1/23/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudioViewController: UIViewController, AVAudioRecorderDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //prepareAudioRecorder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareAudioRecorder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        if !audioRecorder.isRecording {
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch {
                print(error)
            }
        } else {
            audioRecorder.stop()
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                try audioSession.setActive(false)
            } catch {
                print(error)
            }
            
            if verifyFileExists() {
                print("file exists")
            } else {
                print("There was a problem recording.")
            }
        }
        updateRecordButtonTitle()
    }
    
    // MARK: Main
    func prepareAudioRecorder() {
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: URL(fileURLWithPath:audioFileLocation()), settings: audioRecordingSettings())
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playAudioVC = segue.destination as! PlayAudioViewController
            let recordedAudioURL = URL(fileURLWithPath: audioFileLocation())
            playAudioVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: nil)
        } else {
            print("Recorder did not succesffully finish.")
        }
    }
    
    // MARK: Helpers
    func audioFileLocation() -> String {
        return NSTemporaryDirectory().appending("audioRecording.m4a")
    }
    
    func audioRecordingSettings() -> [String: Any] {
        let settings = [AVFormatIDKey: NSNumber.init(value: kAudioFormatAppleLossless),
                        AVSampleRateKey: NSNumber.init(value: 44100.0),
                        AVNumberOfChannelsKey: NSNumber.init(value: 1),
                        AVLinearPCMBitDepthKey: NSNumber.init(value: 16),
                        AVEncoderAudioQualityKey: NSNumber.init(value: AVAudioQuality.high.rawValue)]
        return settings
    }
    
    func updateRecordButtonTitle() {
        if audioRecorder.isRecording {
            recordButton.setTitle("Recording...", for: .normal)
        } else {
            recordButton.setTitle("Record", for: .normal)
        }
    }
    
    func verifyFileExists() -> Bool {
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: self.audioFileLocation())
    }
    
    // MARK: UIPickerViewDataSource methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Constants.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.keys[component].count
    }
    
    // MARK: UIPickerViewDelegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.keys[component][row]
    }
}

