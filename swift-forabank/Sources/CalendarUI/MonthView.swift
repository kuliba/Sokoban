//
//  MonthView.swift
//
//
//  Created by Дмитрий Савушкин on 17.05.2024.
//

import SwiftUI

struct MonthView<DateView>: View where DateView: View {
    
    let calendar: Calendar
    let month: Date
    let dateView: (Date) -> DateView
 
    init(
        calendar: Calendar,
        month: Date,
        @ViewBuilder dateView: @escaping (Date) -> DateView
    ) {
        self.calendar = calendar
        self.month = month
        self.dateView = dateView
    }
 
    private var weeks: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month)
        else { return [] }
        
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: 1)
        )
    }
 
    var body: some View {
        
        VStack {
            
            ForEach(calendar.weeks(month), id: \.self) { week in
                
                WeekView(calendar: calendar, week: week, dateView: self.dateView)
            }
        }
    }
}
