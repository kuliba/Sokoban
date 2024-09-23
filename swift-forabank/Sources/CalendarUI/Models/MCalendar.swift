//
//  MCalendar.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation

public struct MCalendar {

    static var startDate: Date = Calendar.current.date(from: .init(calendar: .current, year: 1992, month: 12, day: 1))!
    static var endDate: Date = Date()
    static var firstWeekday: WeekDay = .monday
    static var locale: Locale = .current
    private static var _calendar: Calendar = .init(identifier: .gregorian)

    private init() {}
}

extension MCalendar {
    static func get() -> Calendar {
    
        var calendar = _calendar
        calendar.timeZone = .current
        return calendar
    }
}
