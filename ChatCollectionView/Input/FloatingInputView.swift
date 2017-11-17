//
//  FloatingInputView.swift
//  ChatCollectionView
//
//  Created by François Rouault on 08/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import Foundation
import UIKit

class KeyboardObserver {
    
    static let shared: KeyboardObserver = {
        let instance = KeyboardObserver()
        NotificationCenter.default.addObserver(instance, selector: #selector(keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        return instance
    }()
    
    @objc func keyboardNotification(notification: NSNotification) {
    }
    
}

class FloatingInputView: UIView {
   
    static var current: FloatingInputView?
    
    weak var collectionView: UIScrollView!
    weak var viewController: UIViewController!
    weak var bottomConstraint: NSLayoutConstraint!
    var firstResponder: UIView? {
        return findFirstResponder(in: self)
    }
    fileprivate var didLayoutSubviews: (() -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("LAYOUT SUBVIEWS, frame: \(frame)")
        didLayoutSubviews?()
    }
    
    func willAppear() {}
    func willDisappear() {}
    
    func show(in vc: UIViewController, over cv: UICollectionView) {
        guard FloatingInputView.current == nil else { return print("FloatingInputView: an input view is already displayed.") }
        FloatingInputView.current = self
        initialize(viewController: vc, collectionView: cv)
        willAppear()
        inflate()
    }
    
    func findFirstResponder(in view: UIView) -> UIView? {
        for view in view.subviews {
            if view is UITextInput, view.canBecomeFirstResponder {
                return view
            }
            return findFirstResponder(in: view)
        }
        return nil
    }
}

extension FloatingInputView {
    
    func initialize(viewController: UIViewController, collectionView: UICollectionView) {
        self.viewController = viewController
        self.collectionView = collectionView
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        print("Keyboard notification:")
        if let _ = FloatingInputView.current, let userInfo = notification.userInfo, let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            let isKeyboardVisible = keyboardFrame.origin.y < UIScreen.main.bounds.size.height
            let isInputVisible = !isHidden
            
            print(" - is input visible: \(isInputVisible)")
            
            let keyboardAndInputHeight = keyboardFrame.size.height + (isInputVisible ? self.bounds.height : 0)
            print(" - keyboardAndInputHeight: \(keyboardAndInputHeight)")
            let spaceBeneathCollectionView = UIScreen.main.bounds.size.height - (collectionView.frame.origin.y + collectionView.bounds.height)
            let marginBetweenInputAndLastMessage: CGFloat = 5
            print(" - spaceBeneathCollectionView: \(spaceBeneathCollectionView)")
            let spaceOverCollectionView = isInputVisible ? keyboardAndInputHeight + marginBetweenInputAndLastMessage - spaceBeneathCollectionView : 0
            print(" - spaceOverCollectionView: \(spaceOverCollectionView)")
            
            let previousBottomContentInset = collectionView.contentInset.bottom
            let hasKeyboardHeightIncreased = previousBottomContentInset < spaceOverCollectionView
            
            // content inset
            let contentInset = UIEdgeInsetsMake(0, 0, spaceOverCollectionView, 0)
            collectionView.contentInset = contentInset
            collectionView.scrollIndicatorInsets = contentInset
            
            // scroll
            if isInputVisible  {
                if previousBottomContentInset == 0 {
                    // keyboard was not visible
                    collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + spaceOverCollectionView), animated: true)
                } else if hasKeyboardHeightIncreased {
                    collectionView.setContentOffset(CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y + (collectionView.contentInset.bottom - previousBottomContentInset)), animated: true)
                }
            }
            
            // chat input view
            bottomConstraint?.constant = isKeyboardVisible ? keyboardFrame.size.height : 0
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: {
                            self.superview?.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    private func inflate() {
        didLayoutSubviews =  {
            self.firstResponder?.becomeFirstResponder()
        }
        
        isHidden = false
        translatesAutoresizingMaskIntoConstraints = false
        let cBottom = NSLayoutConstraint(item: viewController.view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        let cLeading = NSLayoutConstraint(item: viewController.view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        let cTrailing = NSLayoutConstraint(item: viewController.view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        viewController.view.addSubview(self)
        viewController.view.addConstraints([cBottom, cLeading, cTrailing])
        
        bottomConstraint = cBottom
        
        setNeedsLayout()
    }
    
    func hide() {
        willDisappear()
        isHidden = true // must be call before endEditing because used for offset computation
        endEditing(true) // will invoke keyboardNotification()
        removeFromSuperview()
        FloatingInputView.current = nil
    }
    
}
