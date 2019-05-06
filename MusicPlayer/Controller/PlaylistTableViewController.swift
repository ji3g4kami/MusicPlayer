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

class PlaylistTableViewController: UITableViewController {
    
    @IBOutlet var tableFooterView: UIView!
    let mediaItemContainer: MediaItemContainer = MediaSearchEngine().getPlaylist()
    
    lazy var playlist: [SongItem] = mediaItemContainer.playlistMembersip!
    var nextMediaContainer: MediaItemContainer?
    
    @IBAction func playAllButtonPresssed(_ sender: UIButton) {
        AudioPlaybackManager.shared.play(mediaItemContainer)
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


