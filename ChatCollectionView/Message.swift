//
//  Message.swift
//  ChatCollectionView
//
//  Created by François Rouault on 02/08/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import Foundation
import UIKit

class Message: ChatMessageDataSource, CustomStringConvertible {
    
    enum From {
        case platform1(String)
        case platform2(String)
        case user
        
        var color: UIColor {
            switch self {
            case .platform1:
                return UIColor.red
            case .platform2:
                return UIColor.black
            case .user:
                return UIColor.firekast
            }
        }
        
        var author: String {
            switch self {
            case .platform1(let author):
                return author
            case .platform2(let author):
                return author
            case .user:
                return "Me"
            }
        }
    }
    
    var message: String
    let from: From
    
    var text: String
    var backgroundColor: UIColor
    var buttons: [ChatButton]?
    var clickCallback: (() -> ())?
    
    init(message: String, from: From, click: (() -> ())? = nil) {
        self.from = from
        self.message = message
        // ChatMessageDataSource
        self.text = String(format: "%@: %@", from.author, self.message)
        self.backgroundColor = from.color.withAlphaComponent(0.6)
        self.clickCallback = click
    }
    
    var description: String {
        return "Message{text: \(self.text), buttons: \(self.buttons?.flatMap { $0.title } ?? [String]())}"
    }
    
}
