//
//  Utils.swift
//  ChatCollectionView
//
//  Created by François Rouault on 09/11/2017.
//  Copyright © 2017 Cocorico Studio. All rights reserved.
//

import Foundation
import UIKit

let loremIpsum = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Maecenas condimentum tellus lectus, id imperdiet risus pharetra in. Praesent tristique tortor et ornare tempus. In dolor tortor, feugiat sed dui vitae, suscipit efficitur ipsum. Donec nisi eros, suscipit nec ornare congue, aliquam vel metus. Pellentesque sodales nisi a ante gravida placerat.
Aliquam vulputate pulvinar fringilla. Fusce sem risus, accumsan venenatis accumsan non, faucibus eu nisl. Aenean eget dolor odio. Ut bibendum nibh a est malesuada tempor.
Pellentesque posuere ex sapien, et interdum neque placerat nec. Donec magna nisi, aliquet id maximus eu, malesuada sit amet purus. Sed aliquet euismod neque sed eleifend. Aliquam placerat tellus in elit varius hendrerit.
Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Donec sagittis molestie orci rhoncus suscipit. Suspendisse accumsan finibus justo sit amet porta. Curabitur vehicula, turpis vel tempus venenatis, metus augue ullamcorper urna, id ullamcorper augue ex hendrerit libero. Morbi rhoncus auctor accumsan. Etiam at scelerisque erat. Praesent elementum, urna eu pellentesque faucibus, massa purus facilisis dui, a venenatis ligula felis nec justo.
"""

func randomInt(min: Int, max: Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}

extension UIColor {
    static let firekast = UIColor(red: 0xFF/255.0, green: 0xB8/255.0, blue: 0, alpha: 1)
}

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.4
        let ratio = 0.4
        animation.values = [-20.0 * ratio, 20.0 * ratio, -20.0 * ratio, 20.0 * ratio, -10.0 * ratio, 10.0 * ratio, -5.0 * ratio, 5.0 * ratio, 0.0 * ratio]
        layer.add(animation, forKey: "shake")
    }
}

extension String {
    var isEmailAddress: Bool  {
        let emailRegex = ".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
}

