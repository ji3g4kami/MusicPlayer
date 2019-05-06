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

class MusicViewController: ShortcutViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    
    let audioManager = AudioPlaybackManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = userdefaultsKey
        setupCover()
        addSiriButton()
    }
    
    private func setupCover() {
        guard let songlist = MediaSearchEngine().getPlaylist().playlistMembersip else { return }
        if let index = songlist.lastIndex(where: { $0.title == userdefaultsKey }) {
            coverImage.image = UIImage(named: Planet[index])
        }
    }
    
    private func addSiriButton() {
        
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { [unowned self] (allVoiceShortcuts, error) in
            if let allVoiceShortcuts = allVoiceShortcuts {
                if let identifier = UserDefaults.standard.string(forKey: self.mediaItemContainer.title),
                    let shortcut = allVoiceShortcuts.first(where: { (voiceShortcut) -> Bool in
                        return voiceShortcut.shortcut.intent?.identifier == identifier
                    })?.shortcut {
                    self.siriButton.shortcut = shortcut
                    self.siriButton.delegate = self
                } else {
                    let intent = self.mediaItemContainer.intent
                    intent.suggestedInvocationPhrase = "Play \(self.mediaItemContainer.title)"
                    self.siriButton.shortcut = INShortcut(intent: intent)
                    self.siriButton.delegate = self
                }
            }
        }
        
        siriButton.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(siriButton)
        footerView.centerXAnchor.constraint(equalTo: siriButton.centerXAnchor).isActive = true
        footerView.centerYAnchor.constraint(equalTo: siriButton.centerYAnchor).isActive = true
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
    
    deinit {
        print("\(String(describing: userdefaultsKey)) is deinited")
    }
}
