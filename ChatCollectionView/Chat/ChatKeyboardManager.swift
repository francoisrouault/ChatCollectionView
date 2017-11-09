//
//  ChatKeyboardManager.swift
//  ChatCollectionView
//
//  Created by François Rouault on 08/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import Foundation
import UIKit

class ChatKeyboardManager {
    
    weak var collectionView: UICollectionView!
    weak var chatInputView: ChatInputView!
    weak var chatInputViewBottomConstraint: NSLayoutConstraint!
    
    init(chatInputView: ChatInputView, collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.chatInputView = chatInputView
        chatInputView.isHidden = true
        chatInputViewBottomConstraint = chatInputView.superview?.constraints.first {
            return ($0.firstItem is ChatInputView && $0.firstAttribute == .bottom) || ($0.secondItem is ChatInputView && $0.secondAttribute == .bottom)
        }
        assert(chatInputViewBottomConstraint != nil, "ChatInputView must have a bottom constraint.")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo, let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            let isKeyboardVisible = keyboardFrame.origin.y < UIScreen.main.bounds.size.height
            let isInputVisible = !chatInputView.isHidden
            
            print("Keyboard notification:")
            print(" - is input visible: \(isInputVisible)")
            
            let keyboardAndInputHeight = keyboardFrame.size.height + (isInputVisible ? chatInputView.bounds.height : 0)
            print(" - keyboardAndInputHeight: \(keyboardAndInputHeight)")
            let spaceBeneathCollectionView = UIScreen.main.bounds.size.height - (collectionView.frame.origin.y + collectionView.bounds.height)
            let marginBetweenInputAndLastMessage: CGFloat = 5
            print(" - spaceBeneathCollectionView: \(spaceBeneathCollectionView)")
            let spaceOverCollectionView = isInputVisible ? keyboardAndInputHeight + marginBetweenInputAndLastMessage - spaceBeneathCollectionView : 0
            print(" - spaceOverCollectionView: \(spaceOverCollectionView)")
            
            // content inset
            let contentInset = UIEdgeInsetsMake(0, 0, spaceOverCollectionView, 0)
            collectionView.contentInset = contentInset
            collectionView.scrollIndicatorInsets = contentInset
            
            // chat input view
            chatInputViewBottomConstraint.constant = isKeyboardVisible ? keyboardFrame.size.height : 0
            
            // scroll
            if isInputVisible {
                collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + spaceOverCollectionView), animated: true)
            }
            
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            self.chatInputView?.superview?.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func show() {
        chatInputView.isHidden = false
        chatInputView.textView.becomeFirstResponder()
    }
    
    func hide() {
        chatInputView.isHidden = true
        chatInputView.textView.resignFirstResponder()
    }
    
}
