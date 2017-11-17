//
//  TextInputView.swift
//  ChatCollectionView
//
//  Created by François Rouault on 08/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import UIKit

protocol ChatInputViewDelegate: class {
    func chatInputView(_ chatInputView: TextInputView, willAppear: Bool)
    func chatInputView(_ chatInputView: TextInputView, willDisappear: Bool)
    func chatInputView(_ chatInputView: TextInputView, didClickSend withInputText: String)
    func chatInputView(_ chatInputView: TextInputView, inputDidChange text: String)
}

class TextInputView: FloatingInputView, UITextViewDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    
    var delegate: ChatInputViewDelegate? {
        didSet {
            delegate?.chatInputView(self, inputDidChange: textView.text!)
        }
    }
//    var didClickSend: ((ChatInputView, String) -> ())!
//    var shouldShowSendButton: ((String) -> (Bool))! {
//        didSet {
//            textViewDidChange(textView)
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {
        Bundle.main.loadNibNamed("TextInputView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //  contentView.translatesAutoresizingMaskIntoConstraints = true
        
        textView.delegate = self
    }
    
    func clearText() {
        textView.text = ""
        delegate?.chatInputView(self, inputDidChange: textView.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.chatInputView(self, inputDidChange: textView.text)
    }
    
    @IBAction func clickSend(_ sender: Any) {
        delegate?.chatInputView(self, didClickSend: textView.text)
    }
}
