//
//  MusicHelper.swift
//  coronarun
//
//  Created by Brian Limaye on 7/10/20.
//  Copyright © 2020 Brian Limaye. All rights reserved.
//

import Foundation
import AVFoundation

class MusicHelper {
    static let sharedHelper = MusicHelper()
    var audioPlayer: AVAudioPlayer?

    func prepareToPlay() {
        let aSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "chill-background-music", ofType: "mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: aSound as URL)
            audioPlayer!.numberOfLoops = -1
            audioPlayer!.prepareToPlay()
        } catch {
            print("Cannot play the file")
        }
    }
}
