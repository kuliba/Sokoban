//
//  Month.swift
//
//
//  Created by Дмитрий Савушкин on 21.05.2024.
//

import Foundation
 
struct Month {
    
    let month: Date
    let items: [[Date]]
}

// MARK: - Generating Array
extension [Month] {
    
    static func generate() -> Self {
        
        createDatesRange()
            .map(createMonthDate)
            .map(createMonthViewData)
    }
}
private extension [Month] {
    
    static func createDatesRange() -> ClosedRange<Int> { 
        let startDate = MCalendar.startDate, endDate = MCalendar.endDate
        guard startDate <= endDate else { fatalError("Start date must be lower than end date") }

        let numberOfMonthsBetweenDates = startDate.distance(to: endDate, in: .month)
        return 0...Swift.min(numberOfMonthsBetweenDates, 10)
    }
    
    static func createMonthDate(_ index: Int) -> Date { MCalendar.startDate.adding(index, .month) }
    static func createMonthViewData(_ monthStart: Date) -> Month { .generate(monthStart) }
}

// MARK: - Generating Single Month
private extension Month {
    
    static func generate(_ month: Date) -> Self {
        let rawDates = createRawDates(month)
        let groupedDates = groupDates(rawDates)

        return .init(month: month, items: groupedDates)
    }
}
private extension Month {
    
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
private extension Month {
    
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
private extension Month {
    
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
private extension Month {
    
    static var weekdaysNumber: Int { WeekDay.allCases.count }
}
