//
//  MCalendar.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation

struct MCalendar {
    
    static var startDate: Date = .now.start(of: .year)
    static var endDate: Date = .distantFuture.end(of: .month)
    static var firstWeekday: WeekDay = .monday
    static var locale: Locale = .autoupdatingCurrent
    private static var _calendar: Calendar = .init(identifier: .gregorian)

    private init() {}
}

extension MCalendar {
    static func get() -> Calendar { _calendar }
}
