//
//  Date+ext.swift
//  
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation

// MARK: - Comparing
public extension Date {
    
    func isLater(
        _ component: Calendar.Component,
        than date: Date?
    ) -> Bool {
        getDateComparisonResult(component, date) == .orderedDescending
    }
    
    func isBefore(
        _ component: Calendar.Component,
        than date: Date?
    ) -> Bool {
        getDateComparisonResult(component, date) == .orderedAscending
    }
    
    func isSame(
        _ component: Calendar.Component,
        as date: Date?
    ) -> Bool {
        getDateComparisonResult(component, date) == .orderedSame
    }
}

private extension Date {
    
    func getDateComparisonResult(
        _ component: Calendar.Component,
        _ date: Date?
    ) -> ComparisonResult {
        MCalendar.get().compare(self, to: date ?? .distantPast, toGranularity: component)
    }
}

// MARK: - Calculating Difference
extension Date {
    
    func distance(
        to date: Date,
        in component: Calendar.Component
    ) -> Int {
        //TODO: MCalendar remove, create component
        MCalendar.get().dateComponents([component], from: self, to: date).value(for: component) ?? 0
    }
}

// MARK: - Adding
extension Date {
    
    func adding(
        _ value: Int,
        _ component: Calendar.Component
    ) -> Date {
        MCalendar.get().date(byAdding: component, value: value, to: self) ?? self
    }
}

// MARK: - Start & End
public extension Date {
    
    func start(
        of component: Calendar.Component
    ) -> Date {
        MCalendar.get().dateInterval(of: component, for: self)?.start ?? .distantPast
    }
    
    func end(
        of component: Calendar.Component
    ) -> Date {
        MCalendar.get().dateInterval(of: component, for: self)?.end ?? .distantPast
    }
}

// MARK: - Getting Weekday
extension Date {
    func getWeekday() -> WeekDay {
        .init(rawValue: MCalendar.get().component(.weekday, from: self)) ?? .monday
    }
}


// MARK: - Helpers
extension Date {
    static var now: Date { .init() }
}

extension DateFormatter {
    
    static var shortDate: DateFormatter {

        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.long

        dateFormatter.dateFormat =  "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        return dateFormatter
    }
}

public extension Date {
    
    static var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    static var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    static var startOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: Date())

        return  calendar.date(from: components)!
    }
    
    static func date(_ date: Date, addCalendarComponents calendarComponents: Calendar.Component, amount: Int) -> Date? {
        var components: DateComponents = DateComponents.init()
        let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        switch calendarComponents {
        case .second:
            components.second = amount
            break
        case .minute:
            components.minute = amount
            break
        case .hour:
            components.hour = amount
            break
        case .day:
            components.day = amount
            break
        case .weekOfMonth:
            components.weekOfMonth = amount
            break
        case .month:
            components.month = amount
            break
        case .year:
            components.year = amount
            break
        default:
            break
        }
        return gregorian.date(byAdding: components, to: date)
    }
}
