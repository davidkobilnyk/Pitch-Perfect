//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by David Kobilnyk on 5/25/15.
//  Copyright (c) 2015 David Kobilnyk. All rights reserved.
//
//  Code concepts and portions adapted from Udacity course "Intro to iOS App Development with Swift"
//

import Foundation

/**
 A basic object for holding info about a file containing some recorded audio.
 It is used for passing recorded audio info to another screen.
 We use a class instead of a struct because we can't pass a struct to performSegueWithIdentifier.
 */
final class RecordedAudio: NSObject {
    /** Local path to the audio file. */
    private(set) var filePathUrl: NSURL!
    /** A brief title for the audio. */
    private(set) var title: String!
    
    init(filePathUrl: NSURL!, title: String!) {
        self.filePathUrl = filePathUrl
        self.title = title
        super.init()
    }
}
