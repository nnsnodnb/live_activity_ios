//
//  TimeInterval+Extension.swift
//  LiveActivity
//
//  Created by Oka Yuya on 2018/05/04.
//  Copyright © 2018年 Oka Yuya. All rights reserved.
//

import Foundation

extension TimeInterval {

    func convertToDateTime(format: String) -> String {
        let time = NSInteger(self)
        return String(format: format, time / 3600, time / 60 % 60, time % 60)
    }
}
