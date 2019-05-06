//
//  PlaylistTableViewController.swift
//  MusicPlayer
//
//  Created by udn on 2019/4/24.
//  Copyright © 2019 dengli. All rights reserved.
//

import UIKit
import Intents
import IntentsUI
import AudioCastKit

class PlaylistTableViewController: ShortcutTableViewController {
    
    @IBOutlet var tableFooterView: UIView!

    lazy var playlist: [SongItem] = mediaItemContainer.playlistMembersip!
    var nextMediaContainer: MediaItemContainer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSiriButton()
    }
    
    @IBAction func playAllButtonPresssed(_ sender: UIButton) {
        AudioPlaybackManager.shared.play(mediaItemContainer)
    }
    
    /// - Tag: add_to_siri_button
    private func addSiriButton() {
        
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { [unowned self] (allVoiceShortcuts, error) in
            if let allVoiceShortcuts = allVoiceShortcuts {
                if let identifier = UserDefaults.standard.string(forKey: self.mediaItemContainer.title),
                    let shortcut = allVoiceShortcuts.first(where: { (voiceShortcut) -> Bool in
                        return voiceShortcut.shortcut.intent?.identifier == identifier
                    })?.shortcut {
                    print(identifier)
                    self.siriButton.shortcut = shortcut
                } else {
                    let intent = self.mediaItemContainer.intent
                    intent.suggestedInvocationPhrase = "Play all music"
                    self.siriButton.shortcut = INShortcut(intent: intent)
                }
            }
        }
        
        siriButton.delegate = self
        
        siriButton.translatesAutoresizingMaskIntoConstraints = false
        tableFooterView.addSubview(siriButton)
        tableFooterView.centerXAnchor.constraint(equalTo: siriButton.centerXAnchor).isActive = true
        tableFooterView.centerYAnchor.constraint(equalTo: siriButton.centerYAnchor).isActive = true
        
        tableView.tableFooterView = tableFooterView
    }
    
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        super.restoreUserActivityState(activity)
        navigationController?.popToRootViewController(animated: true)
        if let mediaContainerID = activity.userInfo?[NSUserActivity.MediaItemContainerIDKey] as? String,
            let container = try? MediaSearchEngine().getSong(from: mediaContainerID) {
            nextMediaContainer = container
            performSegue(withIdentifier: "toMusicVC", sender: nil)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        cell.textLabel?.text = playlist[indexPath.row].title
        cell.imageView?.image = UIImage(named: Planet[indexPath.row]) 
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toMusicVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMusicVC" {
            guard let musicVC = segue.destination as? MusicViewController else { return }
            if let nextContainer = nextMediaContainer {
                musicVC.mediaItemContainer = nextContainer
                nextMediaContainer = nil
            } else if let index = tableView.indexPathForSelectedRow?.row {
                let title = playlist[index].title
                let mediaItemContainer = try! MediaSearchEngine().getSong(from: title)
                musicVC.mediaItemContainer = mediaItemContainer
            }
        }
    }
}


