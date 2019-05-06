//
//  IntentHandler.swift
//  AudioCastKitIntents
//
//  Created by udn on 2019/5/3.
//  Copyright © 2019 dengli. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is INPlayMediaIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return PlayMediaIntentHandler()
    }
}
