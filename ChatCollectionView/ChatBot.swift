//
//  ChatBot.swift
//  ChatCollectionView
//
//  Created by François Rouault on 09/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class ChatBot {
    
    let kKeyFirstTime = "skip-hello1"
    
    weak var viewController: UIViewController!
    weak var collectionView: ChatCollectionView!
    
    var currentStep: Step = .hello
    var messageLoading: Message?
    var shouldShowHello: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: kKeyFirstTime)
        }
        set {
            UserDefaults.standard.set(!shouldShowHello, forKey: kKeyFirstTime)
        }
    }
    var isLog: Bool {
        return User.current != nil
    }
    var hasApplication = false
    var hasPermissions: Bool {
        return PermissionManager.isAccessCameraGranted && PermissionManager.isAccessMicrophoneGranted
    }
    var email: String?
    var password: String?
    
    enum Step {
        case hello
        case permissions
        case error
        case login
        case createApp
    }
    
    init(viewController: UIViewController, collectionView: ChatCollectionView) {
        self.viewController = viewController
        self.collectionView = collectionView
        if shouldShowHello {
            showHello()
        } else {
            showNext()
        }
    }
    
    func showNext(after: TimeInterval = 0) {
        func exe() {
            if !PermissionManager.isAccessMicrophoneGranted || !PermissionManager.isAccessCameraGranted {
                showPermissions()
                return
            }
            if !isLog {
                showLogin()
                return
            }
            if !hasApplication {
                showCreateApp()
                return
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            exe()
        }
    }
    
    func showLogin() {
        currentStep = .login
        // ask
        let message = Message(message: "To continue, you need to sign in, or create an account.", from: .sLive)
        let button = ChatButton(title: "Fair enough, let's do it.", titleColor: nil) {
            let inputView = LoginInputView(frame: CGRect.zero)
            inputView.delegate = {
                email, password in
                inputView.hide()
                self.email = email
                self.password = password
                let message = Message(message: "Oh oui ça m'excite:\n - \(email)\n - \(password)", from: .user)
                self.collectionView.reloadData(with: message)
                // loading
                self.messageLoading = Message(message: "Signing in / up...", from: .sLive)
                self.collectionView.reloadData(with: self.messageLoading!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    [weak self] in
//                    guard let SELF = self else {
//                        return
//                    }
                    User.logIn()
                    let message = Message(message: "Vous êtes connecté.", from: .sLive)
                    self?.collectionView.reloadData(with: message)
                    self?.showNext(after: 2.0)
                })
            }
            inputView.show(in: self.viewController, over: self.collectionView)
        }
        message.buttons = [button]
        collectionView.reloadData(with: message)
    }
    
    func showCreateApp() {
        currentStep = .createApp
        let message = Message(message: "Create an firekast app to view your stream again, any time.", from: .sLive)
        let button = ChatButton(title: "Ok", titleColor: nil) {
            let inputView = CreateAppInputView(frame: CGRect.zero)
            inputView.delegate = { applicationName in
                inputView.hide()
                let message = Message(message: "Creating your app...", from: .sLive)
                self.collectionView.reloadData(with: message)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    let message = Message(message: "Firekast app created.", from: .sLive)
                    self.collectionView.reloadData(with: message)
                })
            }
            inputView.show(in: self.viewController, over: self.collectionView)
        }
        message.buttons = [button]
        collectionView.reloadData(with: message)
    }
    
    func showHello() {
        currentStep = .hello
        let message = Message(message: "HelloChatBot welcome you to discover this brand new collectionview. Very poPO-po-WerFul ! This is just a preview, so let's imagine how powerful it is ! #swag #weshwesh", from: .sLive)
        collectionView.reloadData(with: message)
        showNext(after: 2.0)
    }
    
    func showPermissions() {
        currentStep = .permissions
        let message = Message(message: "You have to accept the following permissions to let firekast stream.", from: .sLive)
        PermissionManager.shared.delegateAllGranted = {
            self.showNext()
        }
        var buttons = [ChatButton]()
        if !PermissionManager.isAccessCameraGranted {
            let buttonCamera = ChatButton(title: "Camera", titleColor: nil) {
                PermissionManager.shared.requestCameraAccess()
            }
            buttons.append(buttonCamera)
        }
        if !PermissionManager.isAccessMicrophoneGranted {
            let buttonMicrophone = ChatButton(title: "Microphone", titleColor: nil) {
                PermissionManager.shared.requestMicrophoneAccess()
            }
            buttons.append(buttonMicrophone)
        }
        message.buttons = buttons
        collectionView.reloadData(with: message)
    }
    
    func checkPermissions() {
        if !PermissionManager.isAccessCameraGranted || !PermissionManager.isAccessMicrophoneGranted {
            showPermissions()
        }
    }
}
