//
//  Constants.swift
//  Name Your Key
//
//  Created by Paul Crompton on 1/24/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import Foundation

struct Constants {
    static let blackKey = "♯/♭"
    static let keys = [
        ["C", blackKey, "D", blackKey, "E", "F", blackKey, "G", blackKey, "A", blackKey, "B"],
        ["Major", "Minor"]
    ]
    static let stack = CoreDataStack(modelName: "Model")!
}
