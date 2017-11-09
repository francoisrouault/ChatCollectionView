//
//  ChatMessageDataSource.swift
//  ChatCollectionView
//
//  Created by François Rouault on 09/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import Foundation
import UIKit

typealias ChatButtonClickHandler = () -> ()
typealias ChatMessageClickHandler = () -> ()

struct ChatButton {
    let title: String
    /// Default is ChatMessageCell's tint color
    let titleColor: UIColor?
    let action: ChatButtonClickHandler
}

protocol ChatMessageDataSource {
    var text: String { get}
    var backgroundColor: UIColor { get }
    var buttons: [ChatButton]? { get }
    var clickCallback: ChatMessageClickHandler? { get }
}
