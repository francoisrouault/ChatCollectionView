//
//  ChatCollectionView.swift
//  ChatCollectionView
//
//  Created by François Rouault on 30/07/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import UIKit

/**
 Displays ChatMessageDataSource items from the bottom. By default, automatic scroll to bottom is enabled, get disabled when user starts scrolling and remains disabled until user reach the bottom of the list.
 */
class ChatCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let kFadingTopPercentage: Double = 0.35
    let kHeaderResuseId = "headerId"
    let kChatMessageCellResuseId = "cellId"
    let kCollectionViewCellSeparatorHeight: CGFloat = 8
    
    var chatMessages = [ChatMessageDataSource]()
    var cellSizeCache = [Int: CGSize]()
    var firstTime = true
    private var numberOfNewMessagesSinceScrollDisabled: Int = 0 {
        didSet {
            if oldValue != numberOfNewMessagesSinceScrollDisabled {
                numberOfUnreadMessagesDidChange?(oldValue, numberOfNewMessagesSinceScrollDisabled)
            }
        }
    }
    var isAutoScrollToBottomEnabled = true
    var numberOfUnreadMessagesDidChange: ((_ from: Int, _ to: Int) -> ())?
    var isEmpty: Bool {
        get {
            return chatMessages.isEmpty
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
        self.delegate = self
        initCollectionView()
    }
    
    override func layoutSubviews() {
        func addAlphaGradient() {
            let transparent = UIColor.clear.cgColor
            let opaque = UIColor.black.cgColor
            
            let maskLayer = CALayer()
            maskLayer.frame = self.bounds
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRect(x: self.bounds.origin.x, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
            gradientLayer.colors = [transparent, opaque]
            gradientLayer.locations = [0, NSNumber(floatLiteral: kFadingTopPercentage)]
            
            maskLayer.addSublayer(gradientLayer)
            self.layer.mask = maskLayer
        }
        super.layoutSubviews()
        addAlphaGradient()
    }
    
    func initCollectionView() {
        // header (cf. headerReferenceSize)
        register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderResuseId)
        // cell
        let nib = UINib(nibName: "ChatMessageCell", bundle: nil)
        register(nib, forCellWithReuseIdentifier: kChatMessageCellResuseId)
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = kCollectionViewCellSeparatorHeight
            flowLayout.headerReferenceSize = CGSize(width: self.frame.width, height: frame.height) // this is a "hack" for the first cell to appear from the bottom of the collectionView
        }
    }
    
    func clear() {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.headerReferenceSize = CGSize(width: frame.width, height: frame.height)
        }
        chatMessages.removeAll()
        cellSizeCache.removeAll()
        reloadData()
    }
    
    func reloadData(with item: ChatMessageDataSource) {
        chatMessages.append(item)
        reloadData()
        if !isAutoScrollToBottomEnabled {
            numberOfNewMessagesSinceScrollDisabled = numberOfNewMessagesSinceScrollDisabled + 1
        } else if chatMessages.count > 1 {
            numberOfNewMessagesSinceScrollDisabled = 0 // it may take a "long" time to reach the bottom
            scrollToBottom()
        }
    }
    
    func scrollToBottom() {
        let count = numberOfItems(inSection: 0)
        if count > 0 {
            let lastItemIndexPath = IndexPath(item: count - 1, section: 0)
            scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
        }
    }
    
    //MARK: - UICollectionView dataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: kChatMessageCellResuseId, for: indexPath) as! ChatMessageCell
        let message = chatMessages[indexPath.row]
        cell.bind(with: message)
        if chatMessages.count == 1 {
            // animate first cell appearance
            cell.transform = CGAffineTransform(translationX: 0, y: cell.frame.height)
            cell.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                cell.transform = .identity
                cell.alpha = 1
            })
        }
        return cell
    }
    
    //MARK: - UICollectionView delegate FlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = cellSizeCache[indexPath.row] {
            return size
        } else if let cell = ChatMessageCell.fromNib() {
            // this cell will never been drawn on screen
            let cellWidth = bounds.width
            let cellHeight = cell.computeCellHeight(cellWidth: cellWidth, message: chatMessages[indexPath.row])
            let cellSize = CGSize(width: cellWidth, height: cellHeight)
            cellSizeCache[indexPath.row] = cellSize
            //            print("\nsizeForItemAt 1:\n - text: \(items[indexPath.row])\n - cellSize: \(cellSize)\n - labelSize: \(cell.label.frame.size)")
            if chatMessages.count == 1 {
                // since we now know the first cell height, reset headerReferenceSize to show first cell with its bottom aligned with the collectionView's bottom
                let collectionViewPaddingTop = bounds.height * CGFloat(self.kFadingTopPercentage)
                var headerHeight = frame.height - cellSize.height
                if headerHeight < collectionViewPaddingTop {
                    headerHeight = collectionViewPaddingTop
                }
                let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
                flowLayout?.headerReferenceSize = CGSize(width: frame.width, height: headerHeight)
            }
            return cellSize
        } else {
            assertionFailure("Unknown case!")
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        chatMessages[indexPath.row].clickCallback?()
    }
    
    // MARK: - Scroll
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let state = scrollView.panGestureRecognizer.state
        switch state {
//        case .possible:
//            print("scroll system")
        case .changed:
            isAutoScrollToBottomEnabled = false
        default:
            break
        }
        if Int(scrollView.contentOffset.y) >= Int((scrollView.contentSize.height - (scrollView.frame.size.height - scrollView.contentInset.bottom))) {
            numberOfNewMessagesSinceScrollDisabled = 0
            isAutoScrollToBottomEnabled = true
        }
    }
    
}
