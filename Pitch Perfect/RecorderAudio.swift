//
//  RecorderAudio.swift
//  Pitch Perfect
//
//  Created by Ioannis Tornazakis on 8/12/14.
//  Copyright (c) 2014 Ioannis Tornazakis. All rights reserved.
//
//  Description:
//  -   The RecorderAudio class implements the Model component
//      of the apps MVC model.
//  -   It holds the title and the path for an audio recording
//      and is used to pass these data from the
//      RecordSoundsViewController to the PlaySoundsViewController

import Foundation

class RecordedAudio: NSObject{
    
    // MARK: Attributes

    var filePathUrl: NSURL!
    var title: String!
    

    /**
        Default constructor
    */
    init( filePathUrl: NSURL, title: String ) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}