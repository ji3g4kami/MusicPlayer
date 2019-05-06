//
//  ShortcutViewController.swift
//  MusicPlayer
//
//  Created by udn on 2019/5/3.
//  Copyright © 2019 dengli. All rights reserved.
//
import UIKit
import Intents
import IntentsUI
import AudioCastKit

class ShortcutViewController: UIViewController, ShortcutController {
    var siriButton = INUIAddVoiceShortcutButton(style: .whiteOutline)
    var mediaItemContainer: MediaItemContainer = MediaSearchEngine().getPlaylist() // this will soon be replaced
    var userdefaultsKey: String {
        return mediaItemContainer.title
    }
}

extension ShortcutViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        addVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        editVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

extension ShortcutViewController: INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        self.siriButton.shortcut = voiceShortcut?.shortcut
        let identifier = voiceShortcut?.shortcut.intent?.identifier
        UserDefaults.standard.set(identifier, forKey: self.userdefaultsKey)
        controller.dismiss(animated: true)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true) { [unowned self] in
            UserDefaults.standard.removeObject(forKey: self.userdefaultsKey)
        }
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        self.siriButton.shortcut = voiceShortcut?.shortcut
        controller.dismiss(animated: true) { [unowned self] in
            let identifier = voiceShortcut?.shortcut.intent?.identifier
            UserDefaults.standard.set(identifier, forKey: self.userdefaultsKey)
        }
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
