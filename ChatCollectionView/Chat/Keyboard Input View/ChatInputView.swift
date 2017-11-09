//
//  ChatInputView.swift
//  ChatCollectionView
//
//  Created by François Rouault on 08/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import UIKit

class ChatInputView: UIView, UITextViewDelegate {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    
    var delegate: ((ChatInputView, String) -> ())!
    var shouldShowSendButton: ((String) -> (Bool))! {
        didSet {
            textViewDidChange(textView)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {
        Bundle.main.loadNibNamed("ChatInputView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //  contentView.translatesAutoresizingMaskIntoConstraints = true
        
        textView.delegate = self
    }
    
    func clearText() {
        textView.text = ""
        textViewDidChange(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        button.isHidden = !shouldShowSendButton(textView.text)
    }
    
    @IBAction func clickSend(_ sender: Any) {
        delegate(self, textView.text)
    }
}
