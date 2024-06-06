//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation

public enum WeekDay: Int { case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday }

public enum WeekdaySymbolFormat { case veryShort, short, full }

extension WeekDay {
    
    static var allCases: [WeekDay] {
        let firstDayIndex = MCalendar.firstWeekday.rawValue
        let weekDaysIndexes = [Int](firstDayIndex ... 7) + [Int](1 ..< firstDayIndex)

        return .init(weekDaysIndexes)
    }
}

// MARK: - Helpers
fileprivate extension [WeekDay] {
    
    init(_ indexes: [Int]) { self = indexes.compactMap { .init(rawValue: $0) }}
}
