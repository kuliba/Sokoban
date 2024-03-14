//
//  Date+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 01.06.2022.
//

import Foundation

extension Date {
    
    static func dateUTC(with milliseconds: Int) -> Date {

        let adjustment = TimeZone.current.secondsFromGMT()
        let seconds = milliseconds / 1000
        let value = TimeInterval(seconds - adjustment)
        
        return Date(timeIntervalSince1970: value)
    }
}
