//
//  AppDelegate.swift
//  MusicPlayer
//
//  Created by udn on 2019/4/24.
//  Copyright © 2019 dengli. All rights reserved.
//

import UIKit
import Intents
import AudioCastKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    /// - Tag: handle_app_activity
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        // If a user taps on the UI for a media suggestion, the app will open and the media suggestion will be
        // delivered to the app within a NSUserActivity. The activity type string on the activity will be the
        // name of the intent.
        
        guard userActivity.activityType == NSStringFromClass(INPlayMediaIntent.self),
            let mediaIntent = userActivity.interaction?.intent as? INPlayMediaIntent,
            let type = mediaIntent.mediaContainer?.type,
            let mediaContainerID = mediaIntent.mediaContainer?.identifier,
            let navigationController = window?.rootViewController as? UINavigationController
            else {
                return false
        }
        
        // Continuing a user activity should display the content rather than start playback of the content. Pass the
        // user activity to a view controller for display.
        
        if type == .song {
            userActivity.addUserInfoEntries(from: [NSUserActivity.MediaItemContainerIDKey: mediaContainerID])
            restorationHandler(navigationController.viewControllers)
        }
        
        return true
    }
    
    /// - Tag: handle_app
    func application(_ application: UIApplication, handle intent: INIntent, completionHandler: @escaping (INIntentResponse) -> Void) {
        // If a user taps on the play button for a media suggestion, the app will deliver an intent to the intent extension,
        // and if the extension indicates the app can handle the intent, it will be delivered to this method to start playback.
        
        guard let intent = intent as? INPlayMediaIntent,
            let type = intent.mediaContainer?.type,
            let mediaContainerID = intent.mediaContainer?.identifier else {
                print("AppDelegate: Failed to transform intent to INPlayMediaIntent")
                return
        }
        
        if type == .playlist {
            let mediaItemContainer = MediaSearchEngine().getPlaylist()
            AudioPlaybackManager.shared.play(mediaItemContainer)
        } else if type == .song {
            do {
                let mediaItemContainer = try MediaSearchEngine().getSong(from: mediaContainerID)
                AudioPlaybackManager.shared.play(mediaItemContainer)
            } catch {
                print("Failed in AppDelegate's playlist intent handling:", error.localizedDescription)
                let response = INPlayMediaIntentResponse(code: .failure, userActivity: nil)
                completionHandler(response)
                return
            }
        }
        
        let response = INPlayMediaIntentResponse(code: .success, userActivity: nil)
        completionHandler(response)
    }
}
