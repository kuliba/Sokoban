//
//  CalendarView.swift
//
//
//  Created by Дмитрий Савушкин on 16.05.2024.
//

import SwiftUI

struct CalendarView<DateView>: View where DateView: View {
    
    let calendar: Calendar
    let interval: DateInterval
    let content: (Date) -> DateView
 
    init(
        calendar: Calendar,
        interval: DateInterval,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.calendar = calendar
        self.interval = interval
        self.content = content
    }
 
    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
 
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack {
                
                ForEach(months, id: \.self) { month in
                    
                    MonthView(month: month, content: self.content)
                }
            }
        }
    }
}
