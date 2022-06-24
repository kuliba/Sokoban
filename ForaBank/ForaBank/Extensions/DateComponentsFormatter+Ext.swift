//
//  DateComponentsFormatter+Ext.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 13.06.2022.
//

import Foundation

extension DateComponentsFormatter {

    static var formatTime: DateComponentsFormatter {

        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]

        return formatter
    }
}
