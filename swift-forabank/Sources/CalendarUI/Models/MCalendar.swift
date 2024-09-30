//
//  MCalendar.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation

public struct MCalendar {

    var calendar: Calendar
    
    var startDate: Date { return self.calendar.date(from: .init(calendar: calendar, year: 1992, month: 12, day: 1))! }
    static var endDate: Date = Date()
    static var firstWeekday: WeekDay = .monday
    static var locale: Locale = .current
    private static var _calendar: Calendar = .init(identifier: .gregorian)

    public init(calendar: Calendar = .current) {
        
        self.calendar = calendar
        self.calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    }
}

extension MCalendar {
    static func get() -> Calendar {
    
        var calendar = _calendar
        calendar.locale = Locale.current
        calendar.timeZone = .current
        return calendar
    }
}
