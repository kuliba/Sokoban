//
//  DateFormatter.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation

public struct MDateFormatter {}

// MARK: - Date / Weekday -> String Operations
public extension MDateFormatter {
    
    static func getString(
        from date: Date,
        format: String
    ) -> String {
        
        getFormatter(format)
            .string(from: date)
            .capitalized
    }
    
    static func getString(
        for weekday: WeekDay,
        format: WeekdaySymbolFormat
    ) -> String {
        
        switch format {
            case .veryShort: return getFormatter().veryShortWeekdaySymbols[weekday.rawValue - 1].capitalized
            case .short: return getFormatter().shortWeekdaySymbols[weekday.rawValue - 1].capitalized
            case .full: return getFormatter().standaloneWeekdaySymbols[weekday.rawValue - 1].capitalized
        }
    }
}

private extension MDateFormatter {
    
    static func getFormatter(
        _ format: String = ""
    ) -> DateFormatter {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = MCalendar.locale
        dateFormatter.dateFormat = format
        return dateFormatter
    }
}
