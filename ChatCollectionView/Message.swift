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
        case platform1
        case platform2
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
    }
    
    let message: String
    let author: String
    let createdAt: Date
    
    var text: String
    var backgroundColor: UIColor
    var buttons: [ChatButton]?
    var clickCallback: (() -> ())?
    
    init(message: String, author: String, from: From, createdAt: Date, click: (() -> ())? = nil) {
        self.author = author
        self.message = message
        self.createdAt = createdAt
        // ChatMessageDataSource
        if from == .user {
            self.text = String(format: "%@: %@", "Me", self.message)
        } else {
            self.text = String(format: "%@: %@", self.author, self.message)
        }
        self.backgroundColor = from.color.withAlphaComponent(0.6)
        self.clickCallback = click
    }
    
    var description: String {
        return "Message{text: \(self.text), buttons: \(self.buttons?.flatMap { $0.title } ?? [String]())}"
    }
    
}
