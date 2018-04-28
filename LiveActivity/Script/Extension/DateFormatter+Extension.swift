//
//  DateFormatter+Extension.swift
//  LiveActivity
//
//  Created by Oka Yuya on 2018/04/28.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation

extension DateFormatter {

    static var standard: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = NSTimeZone.system
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        return formatter
    }
}
