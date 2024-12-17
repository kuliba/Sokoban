//
//  Helpers.swift
//
//
//  Created by Дмитрий Савушкин on 17.05.2024.
//

import Foundation

extension Calendar {
    
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }

        return dates
    }
    
    func month(_ interval: DateInterval) -> [Date] {
        
        self.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    
    func weeks(_ month: Date) -> [Date] {
        
        guard let monthInterval = self.dateInterval(of: .month, for: month)
        else { return [] }
        
        return self.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: 1)
        )
    }
    
    func days(week: Date) -> [Date] {
        
        guard
            let weekInterval = self.dateInterval(of: .weekOfYear, for: week)
        else { return [] }
        return self.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
}
