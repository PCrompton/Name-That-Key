//
//  Constants.swift
//  Name Your Key
//
//  Created by Paul Crompton on 1/24/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import Foundation

struct Constants {
    static let keys = [
        ["C", "C♯/D♭", "D", "D♯/E♭", "E", "F", "F♯/G♭", "G", "G♯/A♭", "A", "A♯/B♭", "B"],
        ["Major", "Minor"]
    ]
    static let stack = CoreDataStack(modelName: "Model")!
    static let audioFileLocation = NSTemporaryDirectory().appending("audioRecording.m4a")
}
