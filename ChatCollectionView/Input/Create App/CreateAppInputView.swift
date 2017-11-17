//
//  LoginInputView.swift
//  ChatCollectionView
//
//  Created by François Rouault on 13/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import UIKit

class CreateAppInputView: FloatingInputView, UITextFieldDelegate {

    @IBOutlet var contentView: CreateAppInputView!
    @IBOutlet weak var textField: UITextField!
    
    var delegate: ((_ email: String) -> ())!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed("CreateAppInputView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//          contentView.translatesAutoresizingMaskIntoConstraints = true
        
        textField.placeholder = "Application Name"
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            if !text.isEmpty {
                delegate(text)
                return true
            }
            textField.shake()
            return false
        }
        return false
    }
    
    override func willAppear() {
        print("CreateAppInputView will appear")
    }
    
    override func willDisappear() {
        print("CreateAppInputView will disappear")
    }
}
