//
//  TimeInterval+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 09.06.2022.
//

import Foundation

extension TimeInterval {
    
    static func value(days: Int) -> TimeInterval {
        
        TimeInterval(days) * 24 * 60 * 60
    }
}
