//
//  PlayMediaIntentHandler.swift
//  AudioCastKitIntents
//
//  Created by udn on 2019/5/3.
//  Copyright © 2019 dengli. All rights reserved.
//

import Intents
import MediaPlayer

public class PlayMediaIntentHandler: INExtension, INPlayMediaIntentHandling {
    
    public func confirm(intent: INPlayMediaIntent, completion: @escaping (INPlayMediaIntentResponse) -> Void) {
        guard let mediaItem = intent.mediaContainer else {
            completion(INPlayMediaIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        guard mediaItem.type == .playlist || mediaItem.type == .song else {
            completion(INPlayMediaIntentResponse(code: .failureUnknownMediaType, userActivity: nil))
            return
        }
        
        if let title = mediaItem.title {
            let response = INPlayMediaIntentResponse(code: .ready, userActivity: nil)
            response.nowPlayingInfo = [MPMediaItemPropertyTitle: title]
            completion(response)
        } else {
            let response = INPlayMediaIntentResponse(code: .failureNoUnplayedContent, userActivity: nil)
            completion(response)
        }
        
    }
    
    public func handle(intent: INPlayMediaIntent, completion: @escaping (INPlayMediaIntentResponse) -> Void) {
        let response = INPlayMediaIntentResponse(code: .handleInApp, userActivity: nil)
        completion(response)
    }
}
