//
//  PermissionsManager.swift
//  ChatCollectionView
//
//  Created by François Rouault on 09/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PermissionManager {
    
    static let shared: PermissionManager = {
        let mgr = PermissionManager()
        NotificationCenter.default.addObserver(mgr, selector: #selector(mgr.didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        return mgr
    }()
    
    var delegateAllGranted: (() -> ())!
    private var areAllAccessGranted = false

    @objc func didBecomeActive() {
        print("App didBecomeActive")
        // let user see the UI changed, if any
        checkPermissions(after: 0.7, from: "didBecomeActive")
    }
    
    private func openSettings() {
        let settings = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(settings!)
    }
    
    func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            assertionFailure("Not supposed to be clickable if authorized. Check code.")
        case .denied:
            openSettings()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                // this is NOT always main thread (tested)
                // Warning: didBecomeActive will be triggered! But isCameraPermissionGranted() may still be != granted even if granted here.
                print("Cam access granted? \(granted), main thread? \(Thread.isMainThread)")
                DispatchQueue.main.async {
                    self.checkPermissions(after: 0.4, from: "camera request")
                }
            }
        default: break
        }
    }
    
    func requestMicrophoneAccess() {
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            assertionFailure("Not supposed to be clickable if authorized. Check code.")
        case AVAudioSessionRecordPermission.denied:
            openSettings()
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                // this is NOT main thread (tested)
                // Warning: didBecomeActive will be triggered! But isMicrophonePermissionGranted() may still be != granted even if granted here.
                print("Mic access granted? \(granted), main thread? \(Thread.isMainThread)")
                DispatchQueue.main.async {
                    self.checkPermissions(after: 0.4, from: "microphone request")
                }
            }
        }
    }
    
    private func checkPermissions(after: TimeInterval = 0, from: String) {
        let mic = PermissionManager.isAccessMicrophoneGranted
        let cam = PermissionManager.isAccessCameraGranted
        print("Check Permissions:\n - from: \(from)\n - Cam granted? \(cam)\n - Mic granted? \(mic)")
//        DispatchQueue.main.asyncAfter(deadline: .now() + after / 2) {
//            self.showButtonCamera(enabled: cam)
//            self.showButtonMicrophone(enabled: mic)
//        }
        if cam, mic, !areAllAccessGranted {
            areAllAccessGranted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + after) {
                self.delegateAllGranted()
            }
        }
    }
    
    // MARK: - Camera
    
    static var isAccessCameraGranted: Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }
    
    // MARK: - Microphone
    
    static var isAccessMicrophoneGranted: Bool {
        return AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.granted
    }
    
}
