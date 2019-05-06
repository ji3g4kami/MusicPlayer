import Foundation
import Intents


public protocol MediaItem {
    var url: URL { get }
    var title: String { get }
}

public struct SongItem: MediaItem, Equatable {
    public var url: URL
    public var title: String
    
    public static func == (lhs: SongItem, rhs: SongItem) -> Bool {
        return lhs.title == rhs.title
    }
}

public struct PlaylistItem: MediaItem {
    public var url: URL
    public var title: String
    public let playlistMembership: [SongItem]
}

/// A container of a playlist or a music
public struct MediaItemContainer: MediaItem, Equatable {
    
    public init(containerType: ContainerType, url: URL, title: String, artworkName: String?, playlistMembership: [SongItem]?) {
        self.containerType = containerType
        self.url = url
        self.title = title
        self.artworkName = artworkName
        self.playlistMembersip = playlistMembership
    }
    
    public enum ContainerType: UInt {
        case song = 1
        case playlist
    }
    
    public let containerType: ContainerType
    public let url: URL
    public let title: String
    public let artworkName: String?
    public let playlistMembersip: [SongItem]?
    
    public static func == (lhs: MediaItemContainer, rhs: MediaItemContainer) -> Bool {
        return lhs.url == rhs.url
    }
}

extension MediaItemContainer.ContainerType {
    public var mediaItemType: INMediaItemType {
        switch self {
        case .song:
            return .song
        case .playlist:
            return .playlist
        }
    }
}

/// Converts the struct types representing media into equivalent representations for use with the Intents framework
extension MediaItemContainer {
    public var intent: INPlayMediaIntent {
        let intent = INPlayMediaIntent(
            mediaItems: nil,
            mediaContainer: INMediaItem(
                identifier: title,
                title: title,
                type: containerType.mediaItemType,
                artwork: (artworkName != nil) ? INImage(named: artworkName!) : nil
            ),
            playShuffled: false,
            playbackRepeatMode: .none,
            resumePlayback: true
        )
        return intent
    }
}

extension NSUserActivity {
    public static let MediaItemContainerIDKey = "MediaItemContainerID"
}
