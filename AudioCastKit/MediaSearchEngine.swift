//
//  MediaSearchEngine.swift
//  AudioCastKit
//
//  Created by udn on 2019/4/26.
//  Copyright © 2019 dengli. All rights reserved.
//

import Foundation
import Intents

public struct MediaSearchEngine {
    
    public init() {}
    
    public static let playlistURL: [URL] = {
        let url = Bundle(identifier: "com.dengli.AudioCastKit")!.bundleURL
        return try! FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    }()
    
    public static var songlist: [SongItem] {
        let songlist = playlistURL.compactMap { url -> SongItem? in
            if url.absoluteString.hasSuffix("mp3") {
                if let rawSongName = url.absoluteString.components(separatedBy: "/").last {
                    let songName = rawSongName.replacingOccurrences(of: "%20", with: " ")
                        .replacingOccurrences(of: ".mp3", with: "")
                    return SongItem(url: url, title: songName)
                }
            }
            return nil
        }
        return songlist.sorted(by: { (song1, song2) -> Bool in
            song1.title < song2.title
        })
    }
    
    public func getPlaylist() -> MediaItemContainer {
        let mediaItemContainer = MediaItemContainer(
            containerType: .playlist,
            url: MediaSearchEngine.songlist[0].url,
            title: "Play list",
            artworkName: nil,
            playlistMembership: MediaSearchEngine.songlist
        )
        return mediaItemContainer
    }
    
    enum MediaSearchError: Error {
        case invalidURL
        case invalidTitle
    }
    
    public func getSong(from songName: String) throws -> MediaItemContainer {
        guard let songIndex = MediaSearchEngine.songlist.firstIndex(of: SongItem(url: URL(string: "https://google.com")!, title: songName)) else {
            throw MediaSearchError.invalidTitle
        }

        let mediaItemContainer = MediaItemContainer(
            containerType: .song,
            url: MediaSearchEngine.songlist[songIndex].url,
            title: MediaSearchEngine.songlist[songIndex].title,
            artworkName: nil,
            playlistMembership: nil
        )
        return mediaItemContainer
    }
}
