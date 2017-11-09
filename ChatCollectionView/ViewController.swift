//
//  ViewController.swift
//  ChatCollectionView
//
//  Created by François Rouault on 20/10/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: ChatCollectionView!
    @IBOutlet weak var buttonNewMessage: UIButton!
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    @IBOutlet weak var chatInputView: ChatInputView!
   
    var chatKeyboardManager: ChatKeyboardManager!
    
    func createMessageText() -> String {
        let choice = arc4random_uniform(UInt32(50-1)) % 50
        let maxCount: Int
        if 0 <= choice, choice < 5 {
            maxCount = Int(0.3 * Float(loremIpsum.characters.count))
        } else if choice == 6 {
            maxCount = loremIpsum.characters.count
        } else {
            maxCount = 140
        }
        let n = 1 + Int(arc4random_uniform(UInt32(maxCount-1)))
        let end = loremIpsum.index(loremIpsum.startIndex, offsetBy: n)
        let subString = loremIpsum[..<end]
        return String(subString)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        chatKeyboardManager = ChatKeyboardManager(chatInputView: chatInputView, collectionView: collectionView)
        chatInputView.shouldShowSendButton = {
            input in
            return !input.isEmpty
        }
        chatInputView.delegate = {
            view, input in
            view.clearText()
            let message = Message(message: input, author: "Me", from: .user, createdAt: Date()) {
                print("'\(input)' cell clicked")
            }
            self.collectionView.reloadData(with: message)
        }
    }
    
    @IBAction func clickNewMessage(_ sender: UIButton) {
        let text = createMessageText()
        let from = randomInt(min: 0, max: 1) == 0 ? Message.From.platform1 : Message.From.platform2
        let message = Message(message: text, author: "Mike", from: from, createdAt: Date()) {
            print("Cell clicked")
        }
        var buttons = [ChatButton]()
        for i in 0..<randomInt(min: 0, max: 4) {
            let action: () -> () = {
                print("Button \(i) has been clicked.")
            }
            buttons.append(ChatButton(title: "Button \(i)", titleColor: nil, action: action))
        }
        message.buttons = buttons.isEmpty ? nil : buttons
        print("Show: \(message)")
        collectionView.reloadData(with: message)
    }
    
    @IBAction func clickShowKeyboard(_ sender: Any) {
        chatKeyboardManager.show()
    }
    
    @IBAction func clickHideKeyboard(_ sender: Any) {
        chatKeyboardManager.hide()
    }
    
    @IBAction func clickGoBottom(_ sender: Any) {
        collectionView.scrollToBottom()
    }
}

