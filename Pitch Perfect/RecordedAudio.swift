//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by David Kobilnyk on 5/25/15.
//  Copyright (c) 2015 David Kobilnyk. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl: NSURL!, title: String!) {
        self.filePathUrl = filePathUrl
        self.title = title
        super.init()
    }
}