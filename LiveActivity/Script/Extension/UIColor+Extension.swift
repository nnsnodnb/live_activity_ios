//
//  UIColor+Extension.swift
//  LiveActivity
//
//  Created by Oka Yuya on 2018/05/03.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(hex: String, alpha: CGFloat) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let v = hex.map { String($0) } + Array(repeating: "0", count: max(6 - hex.count, 0))
        let r = CGFloat(Int(v[0] + v[1], radix: 16) ?? 0) / 255.0
        let g = CGFloat(Int(v[2] + v[3], radix: 16) ?? 0) / 255.0
        let b = CGFloat(Int(v[4] + v[5], radix: 16) ?? 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    static var mainOrange: UIColor { return UIColor(hex: "fca24f", alpha: 1.0) }
    static var mainYellow: UIColor { return UIColor(hex: "fcdc4f", alpha: 1.0) }
}
