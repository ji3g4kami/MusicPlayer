//
//  AudioPlayBackManager.swift
//  MusicPlayer
//
//  Created by udn on 2019/4/24.
//  Copyright © 2019 dengli. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import os.log

public class AudioPlaybackManager: NSObject {
    
    public static let shared = AudioPlaybackManager()

    open var playingSong: SongItem?
    
    open var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    private let audioManagerQueue = DispatchQueue(label: "Audio Manager Queue")
    private var mediaItemContainer: MediaItemContainer?
    private var player: AVAudioPlayer?
    private var enabledAudioCommands = [MPRemoteCommand]()
    
    private override init() {
        super.init()
    }
    
    private func createPlayer(with item: MediaItemContainer) {
        do {
            player = try AVAudioPlayer(contentsOf: item.url)
            let playingIndex = item.playlistMembersip?.firstIndex(where: { songItem in
                item.url == songItem.url
            })
            playingSong = item.playlistMembersip?[playingIndex ?? 0]
            mediaItemContainer = item
            if item.containerType == .playlist {
                player?.delegate = self
            }
            
            startAudioControl()
        } catch let error {
            print("Could not create audio player. Reason: \(error.localizedDescription)")
        }
    }
    
    public func play(_ item: MediaItemContainer) {
        stopPlaying()
        audioManagerQueue.sync {
            if player == nil {
                createPlayer(with: item)
            }
            updateNowPlayingCenter()
            player?.play()
        }
    }
    
    public func pause() {
        audioManagerQueue.sync {
            player?.pause()
        }
    }
    
    public func stopPlaying() {
        audioManagerQueue.sync {
            player?.stop()
            stopAudioControl()
            player = nil
        }
    }
    
    private func playNextItem() {
        if let currentSong = playingSong,
            let playlist = mediaItemContainer?.playlistMembersip,
            let currentIndex = playlist.firstIndex(where: { $0 == currentSong }),
            currentIndex + 1 < playlist.count {
            
            let nextPlayingItem = playlist[currentIndex + 1]
            self.playingSong = nextPlayingItem
            let mediaItem = MediaItemContainer(
                containerType: .playlist,
                url: nextPlayingItem.url,
                title: nextPlayingItem.title,
                artworkName: mediaItemContainer?.artworkName,
                playlistMembership: mediaItemContainer?.playlistMembersip
            )
            mediaItemContainer = mediaItem
            startAudioControl()
            play(mediaItem)
        } else {
            stopAudioControl()
        }
    }
    
    private func updateNowPlayingCenter() {
        DispatchQueue.main.async { [weak self] in
            let infoCenter = MPNowPlayingInfoCenter.default()
            
            if let playingItem = self?.playingSong {
                infoCenter.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: playingItem.title
                ]
            } else {
                infoCenter.nowPlayingInfo = nil
            }
        }
    }
    
    /// Sets up the audio session and provides remote control event handling.
    private func startAudioControl() {
        guard enabledAudioCommands.isEmpty else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch let error as NSError {
            os_log("Could not set up audio session. %@", log: OSLog.default, type: .error, error)
        }
        
        let toggleCommand = MPRemoteCommandCenter.shared().togglePlayPauseCommand
        toggleCommand.isEnabled = true
        toggleCommand.addTarget { [weak self] (_) -> MPRemoteCommandHandlerStatus in
            guard let audioPlayer = self?.player else { return .commandFailed }
            
            if audioPlayer.isPlaying {
                audioPlayer.pause()
            } else {
                audioPlayer.play()
            }
            return .success
        }
        enabledAudioCommands.append(toggleCommand)
    }
    
    /// Stops the audio session and removes remote control event hooks.
    private func stopAudioControl() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            player?.stop()
            try audioSession.setActive(false)
        } catch let error as NSError {
            os_log("Could not set up audio session. Reason: %@", log: OSLog.default, type: .error, error)
        }
        
        for command in enabledAudioCommands {
            command.isEnabled = false
            command.removeTarget(nil)
        }
        
        enabledAudioCommands.removeAll()
    }
}

extension AudioPlaybackManager: AVAudioPlayerDelegate {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNextItem()
    }
}

import Intents

extension AudioPlaybackManager {
    open func getIntent() -> INPlayMediaIntent? {
        return mediaItemContainer?.intent
    }
}
