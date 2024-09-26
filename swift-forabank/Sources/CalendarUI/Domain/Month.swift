//
//  Month.swift
//
//
//  Created by Дмитрий Савушкин on 21.05.2024.
//

import Foundation
 
public struct Month {
    
    let month: Date
    let items: [[Date]]
}

// MARK: - Generating Array
extension [Month] {
    //TODO: extract generate and MCalendar
    public static func generate(startDate: Date?) -> Self {
        
        do {
            
            return try createDatesRange()
                .map(createMonthDate)
                .map(createMonthViewData)
        } catch {
            
            return []
        }
    }
}

extension [Month] {
    
    static func createDatesRange() throws -> ClosedRange<Int> {
        let startDate = MCalendar().startDate, endDate = MCalendar.endDate
        guard startDate <= endDate else {
            throw MonthErrors.monthGenerate
        }

        let numberOfMonthsBetweenDates = startDate.distance(to: endDate, in: .month)
        return 0...numberOfMonthsBetweenDates+2
    }
    
    static func createMonthDate(_ index: Int) -> Date {
        
        let date = MCalendar().startDate.adding(index, .month)
        return date
    }
    
    static func createMonthViewData(_ monthStart: Date) -> Month {
        .generate(monthStart)
    }
}

// MARK: - Generating Single Month
extension Month {
    
    static func generate(_ month: Date) -> Self {
        let rawDates = createRawDates(month)
        let groupedDates = groupDates(rawDates)

        return .init(month: month, items: groupedDates)
    }
}

extension Month {
    
    static func createRawDates(_ month: Date) -> [Date] {
        let items = createRawDateItems(month, month.getWeekday())
        return items
    }
    
    static func groupDates(_ rawDates: [Date]) -> [[Date]] {
        rawDates
            .enumerated()
            .reduce(into: [], reduceRawDates)
    }
}

extension Month {
    
    static func createRawDateItems(
        _ monthStartDate: Date,
        _ monthStartWeekday: WeekDay
    ) -> [Date] {
        
        var items: [Date] = []

        for index in 0..<100 {
            
            let date = createRawDate(index, monthStartDate, monthStartWeekday)

            switch shouldStopPopulatingRawDateItems(items, date, monthStartDate) {
                case true: return items
                case false: items.append(date)
            }
        }

        return items
    }
    
    static func reduceRawDates(_ array: inout [[Date]], item: EnumeratedSequence<[Date]>.Iterator.Element) {
        switch item.offset % weekdaysNumber == 0 {
            case true: array.append([item.element])
            case false: array[array.count - 1].append(item.element)
        }
    }
}

extension Month {
    
    static func createRawDate(_ index: Int, _ monthStartDate: Date, _ monthStartWeekday: WeekDay) -> Date {
        let shiftIndex = {
            let index = monthStartWeekday.rawValue - MCalendar.firstWeekday.rawValue
            return index < 0 ? index + weekdaysNumber : index
        }()
        return monthStartDate.adding(index - shiftIndex, .day)
    }
    
    static func shouldStopPopulatingRawDateItems(_ items: [Date], _ date: Date, _ monthStartDate: Date) -> Bool {
        guard items.count % weekdaysNumber == 0 else { return false }
        return date.isLater(.month, than: monthStartDate)
    }
}

extension Month {
    
    static var weekdaysNumber: Int { WeekDay.allCases.count }
}

enum MonthErrors: Error {
    case monthGenerate
}

extension Date {
    
    static func createStartDate(startDate: Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 1992
        dateComponents.month = 5
        dateComponents.day = 1
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0) // Japan Standard Time
        dateComponents.hour = 0
        dateComponents.minute = 00

        // Create date from components
        var userCalendar = Calendar(identifier: .gregorian)
        userCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let someDateTime = userCalendar.date(from: dateComponents)
        
        return someDateTime!
    }
}
