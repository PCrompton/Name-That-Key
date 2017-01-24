//
//  PlayAudioViewController.swift
//  Name Your Key
//
//  Created by Paul Crompton on 1/23/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import UIKit
import AVFoundation

class PlayAudioViewController: UIViewController, AVAudioPlayerDelegate {

    var recordedAudioURL: URL!
    var audioPlayer: AVAudioPlayer!
    
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        playAudio()
        updatePlayButtonTitle()
    }
    
    // MARK: Main
    
    func playAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioPlayer = AVAudioPlayer(contentsOf: recordedAudioURL)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            //playButton.setTitle("Play", for: .normal)
            updatePlayButtonTitle()
        } else {
            print("Player did not succesffully finish.")
        }
    }
    
    // MARK: Helpers
    
    func updatePlayButtonTitle() {
        if audioPlayer.isPlaying {
            playButton.setTitle("Playing...", for: .normal)
        } else {
            playButton.setTitle("Play", for: .normal)
        }
    }
    
}
