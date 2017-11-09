//
//  ChatMessageCell.swift
//  ChatCollectionView
//
//  Created by François Rouault on 24/07/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {

    let kLocalizableRow = "Live"
    
    let kTextMarginTop: CGFloat = 5
    let kTextMarginBottom: CGFloat = 5
    let kTextMarginLeft: CGFloat = 5
    let kTextMarginRight: CGFloat = 5
    
    let kButtonHeight: CGFloat = 57
    let kFirstButtonMarginTop: CGFloat = 15
    let kButtonMarginLeft: CGFloat = 1
    let kButtonMarginRight: CGFloat = 1
    let kButtonsSeplineHeight: CGFloat = 1
    let kLastButtonMarginBottom: CGFloat = 1
    
    let kCornerRadius: CGFloat = 8
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bubble: UIView!
    
    var data: ChatMessageDataSource!
    
    /**
     Allows you to generate a cell without dequeueing one from a table view.
     - Returns: The cell loaded from its nib file.
     */
    class func fromNib() -> ChatMessageCell? {
        let nibViews = Bundle.main.loadNibNamed("ChatMessageCell", owner: nil, options: nil)
        for nibView in nibViews! {
            if let cellView = nibView as? ChatMessageCell {
                return cellView
            }
        }
        return nil
    }

    func computeCellHeight(cellWidth: CGFloat, message: ChatMessageDataSource) -> CGFloat {
        let labelWidth = cellWidth - kTextMarginLeft - kTextMarginRight
        label.frame.size.width = labelWidth
        label.text = message.text
        label.sizeToFit() // this will compute label height for the given width
        let buttonsCount = message.buttons?.count ?? 0
        let seplineCount = buttonsCount == 0 ? 0 : (buttonsCount - 1)
        return kTextMarginTop
            + label.frame.height
            + kTextMarginBottom
            + (message.buttons == nil ? 0 : kFirstButtonMarginTop + kLastButtonMarginBottom)
            + CGFloat(buttonsCount) * kButtonHeight + CGFloat(seplineCount) * kButtonsSeplineHeight
    }
    
    private var cellWidthWithLabelSizedToFit: CGFloat {
        return label.bounds.width + kTextMarginLeft + kTextMarginRight
    }
    
    func bind(with message: ChatMessageDataSource) {
        self.data = message
        drawText(with: message)
        drawButtonsEventually(message: message)
        drawBubble(under: message)
    }
    
    private func drawText(with message: ChatMessageDataSource) {
        let labelMaxWidth = frame.size.width - kTextMarginLeft - kTextMarginRight
        label.frame = CGRect(x: kTextMarginLeft, y: kTextMarginTop, width: labelMaxWidth, height: 1)
        label.text = message.text
        label.sizeToFit()
//        label.backgroundColor = UIColor.red
    }
    
    private func drawButtonsEventually(message: ChatMessageDataSource) {
        subviews.filter { $0 is UIButton }.forEach { button in
            button.removeFromSuperview()
        }
        guard let buttons = message.buttons else { return }
        let topOfFirstButtonY = label.frame.origin.y + label.bounds.height + kTextMarginBottom + kFirstButtonMarginTop
        let width = cellWidthWithLabelSizedToFit
        for i in 0..<buttons.count {
            let yButton = topOfFirstButtonY + CGFloat(i) * (kButtonHeight + kButtonsSeplineHeight)
            let rect = CGRect(x: kButtonMarginLeft, y: yButton, width: width - kButtonMarginLeft - kButtonMarginRight, height: kButtonHeight)
            let button = UIButton(frame: rect)
            button.titleLabel?.font = label.font
            self.addSubview(button)
            button.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            button.setTitle(buttons[i].title, for: .normal)
            let titleColor = buttons[i].titleColor ?? tintColor
            button.setTitleColor(titleColor, for: .normal)
            button.setTitleColor(titleColor!.withAlphaComponent(0.4), for: .highlighted)
            button.tag = i
            button.addTarget(self, action: #selector(clickButton(sender:)), for: .touchUpInside)
            if (i == buttons.count - 1 ){
                // last button
                button.roundCorners([.bottomLeft, .bottomRight], radius: kCornerRadius)
            }
        }
    }
    
    @objc func clickButton(sender: UIButton) {
        data.buttons![sender.tag].action()
    }
    
    private func drawBubble(under message: ChatMessageDataSource) {
        let buttonCount = message.buttons?.count ?? 0
        let seplineCount = buttonCount == 0 ? 0 : buttonCount - 1
        let bubbleHeight = kTextMarginTop
                + label.frame.height
                + kTextMarginBottom
                + (message.buttons == nil ? 0 : kFirstButtonMarginTop + kLastButtonMarginBottom)
                + CGFloat(buttonCount) * kButtonHeight + CGFloat(seplineCount) * kButtonsSeplineHeight
        bubble.frame = CGRect(x: 0, y: 0, width: cellWidthWithLabelSizedToFit, height: bubbleHeight)
        bubble.backgroundColor = message.backgroundColor
        bubble.layer.cornerRadius = kCornerRadius
        bubble.layer.masksToBounds = true
    }
    
}

