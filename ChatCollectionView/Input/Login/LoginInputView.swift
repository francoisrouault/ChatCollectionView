//
//  LoginInputView.swift
//  ChatCollectionView
//
//  Created by François Rouault on 13/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import UIKit

class LoginInputView: FloatingInputView, UITextFieldDelegate {

    @IBOutlet var contentView: LoginInputView!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    var delegate: ((_ email: String, _ password: String) -> ())!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed("LoginInputView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//          contentView.translatesAutoresizingMaskIntoConstraints = true
        
        textFieldEmail.delegate = self
        textFieldPassword.delegate = self
//        textFieldEmail.text = "frouo@msn.com"
        textFieldEmail.placeholder = "Email"
        textFieldPassword.placeholder = "Password"
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            textField.shake()
            return false
        }
        // check email
        if !textFieldEmail.text!.isEmailAddress {
            textFieldEmail.shake()
            return false
        }
        // move to password
        if textField == textFieldEmail {
            textFieldPassword.becomeFirstResponder()
            return true
        }
        // password
        if text.count < 6 {
            textFieldPassword.shake()
            return false
        }
        delegate(textFieldEmail.text!, textFieldPassword.text!)
        return true
    }
    
    override func willAppear() {
        print("LoginInputView will appear")
    }
    
    override func willDisappear() {
        print("LoginInputview will disappear")
    }
}
