//
//  WeekView.swift
//  
//
//  Created by Дмитрий Савушкин on 17.05.2024.
//

import SwiftUI

struct WeekView<DateView>: View where DateView: View {
    
    let calendar: Calendar
    let week: Date
    let dateView: (Date) -> DateView
 
    init(
        calendar: Calendar,
        week: Date,
        @ViewBuilder dateView: @escaping (Date) -> DateView
    ) {
        self.calendar = calendar
        self.week = week
        self.dateView = dateView
    }
 
    private var days: [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
            else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
 
    var body: some View {
        
        HStack {
            
            ForEach(calendar.days(week: week), id: \.self) { date in
                
                HStack {
                    
                    if self.calendar.isDate(self.week, equalTo: date, toGranularity: .month) {
                        self.dateView(date)
                    } else {
                        self.dateView(date).hidden()
                    }
                }
            }
        }
    }
}
