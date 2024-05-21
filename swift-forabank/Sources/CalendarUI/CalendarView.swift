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
    let dateView: (Date) -> DateView
    
    init(
        calendar: Calendar,
        interval: DateInterval,
        @ViewBuilder dateView: @escaping (Date) -> DateView
    ) {
        self.calendar = calendar
        self.interval = interval
        self.dateView = dateView
    }
 
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            LazyVGrid(columns: [.init()]) {
                
                VStack {
                    
                    ForEach(calendar.month(interval), id: \.self) { month in
                        
                        MonthView(calendar: calendar, month: month, dateView: self.dateView)
                    }
                }
            }
        }
    }
}
