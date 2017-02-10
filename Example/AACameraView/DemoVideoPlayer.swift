//
//  DemoVideoPlayer.swift
//  AACameraView
//
//  Created by Engr. Ahsan Ali on 07/02/2017.
//  Copyright © 2017 AA-Creations. All rights reserved.
//

import AVKit
import AVFoundation

class DemoVideoPlayer: AVPlayerViewController {

    var movieURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = movieURL {
            player = AVPlayer(url: url)
            player!.play()
        }
    }
}



