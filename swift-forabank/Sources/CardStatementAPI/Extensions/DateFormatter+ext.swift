//
//  DateFormatter+ext.swift
//
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

final class DateFormatterISO8601: DateFormatter {
    
    private let formatter: ISO8601DateFormatter
    
    override init() {
        self.formatter = ISO8601DateFormatter()
        super.init()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFractionalSeconds, .withTimeZone]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func date(from string: String) -> Date? {
        
        formatter.date(from: string)
    }
    
    override func string(from date: Date) -> String {
        
        formatter.string(from: date)
    }
}

extension DateFormatter {
    
    static let iso8601: DateFormatter = DateFormatterISO8601()
}
