//
//  MusicViewController.swift
//  MusicPlayer
//
//  Created by udn on 2019/4/26.
//  Copyright © 2019 dengli. All rights reserved.
//

import UIKit
import Intents
import IntentsUI
import os.log
import AudioCastKit

class MusicViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    
    let audioManager = AudioPlaybackManager.shared
    var mediaItemContainer: MediaItemContainer = MediaSearchEngine().getPlaylist() // this will soon be replaced
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = mediaItemContainer.title
        setupCover()
    }
    
    private func setupCover() {
        guard let songlist = MediaSearchEngine().getPlaylist().playlistMembersip else { return }
        if let index = songlist.lastIndex(where: { $0.title == mediaItemContainer.title }) {
            coverImage.image = UIImage(named: Planet[index])
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        audioManager.play(mediaItemContainer)
        sender.isHidden = true
        pauseButton.isHidden = false
    }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        audioManager.pause()
        sender.isHidden = true
        playButton.isHidden = false
    }
    
    @IBAction func leaveButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
