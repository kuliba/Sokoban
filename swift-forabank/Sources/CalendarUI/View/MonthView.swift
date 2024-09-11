//
//  MonthView.swift
//  
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI

public struct MonthView: View {
    
    var selectedDate: Date?
    var selectedRange: MDateRange?
    
    let data: Month
    let config: CalendarConfig

    let selectDate: (Date) -> Void
    
    public var body: some View {
        
        LazyVStack(spacing: config.daysSpacing.vertical) {
            
            ForEach(data.items, id: \.last, content: singleRow)
        }
        .frame(maxWidth: .infinity)
        .animation(animation, value: selectedDate)
        .animation(animation, value: selectedRange?.getRange())
    }
}

private extension MonthView {
    
    func singleRow(_ dates: [Date]) -> some View {
        
        HStack(spacing: config.daysSpacing.horizontal) {
            
            ForEach(dates, id: \.self, content: dayView)
        }
    }
}

extension MonthView {
    
    func dayView(_ date: Date) -> some View {
        
        DayView(
            date: date,
            isCurrentMonth: isCurrentMonth(date),
            config: config.dayConfig,
            selectedDate: selectedDate,
            selectedRange: selectedRange,
            selectDate: selectDate
        )
        
//        config.dayView(
//            date,
//            isCurrentMonth(date),
//            selectedDate,
//            { selectedRange?.addToRange($0) }
//        ).erased()
    }
}

extension MonthView {
    
    func isCurrentMonth(_ date: Date) -> Bool { data.month.isSame(.month, as: date) }
}

// MARK: - Others
extension MonthView {
    
    var animation: Animation { .spring(response: 0.32, dampingFraction: 1, blendDuration: 0) }
}

// MARK: - Default View Implementation
public extension MonthLabel {
    
    func content() -> AnyView {
        defaultContent().erased()
    }
}
public extension MonthLabel {
    func defaultContent() -> some View {
        
        Text(getString(format: "MMMM y"))
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.gray.opacity(0.4))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

// MARK: - Helpers
public extension MonthLabel {
    /// Returns a string of the selected format for the month.
    func getString(format: String) -> String {
        MDateFormatter.getString(from: month, format: format)
    }
}

// MARK: - Others
public struct MonthLabel: View {
    
    var month: Date
    
    public init(month: Date) {
        self.month = month
    }
    
    public var body: some View {
        content()
    }
}

// MARK: - Default View Implementation
public extension WeekdayLabel {
    func content() -> AnyView {
        defaultContent().erased()
    }
}

public extension WeekdayLabel {
    func defaultContent() -> some View {
        Text(getString(with: .veryShort))
            .foregroundColor(.onBackgroundSecondary)
            .font(.system(size: 14))
    }
}

// MARK: - Helpers
public extension WeekdayLabel {
    /// Returns a string of the selected format for the weekday.
    func getString(with format: WeekdaySymbolFormat) -> String { MDateFormatter.getString(for: weekday, format: format) }

    /// Returns a type-erased object.
//    func erased() -> AnyWeekdayLabel { .init(self) }
}

// MARK: - Others
public struct WeekdayLabel: View {
    
    var weekday: WeekDay
    
    public var body: some View {
        content()
    }
}

// MARK: - Default View Implementation
public extension WeekdaysView {
    
    func content() -> AnyView {
        weekdaysView().erased()
    }
    
    func weekdayLabel(_ weekday: WeekDay) -> WeekdayLabel {
        defaultWeekDayLabel(weekday)
    }
}
public extension WeekdaysView {
    func defaultWeekDayLabel(_ weekday: WeekDay) -> WeekdayLabel {
        WeekdayLabel(weekday: weekday)
    }
}

// MARK: - Helpers
public extension WeekdaysView {
    /// Creates weekdays view using the selected weekday labels. Cannot be overriden.
    func weekdaysView() -> some View { HStack(spacing: 0) { ForEach(WeekDay.allCases, id: \.self, content: weekdayItem) } }
}
private extension WeekdaysView {
    func weekdayItem(_ weekday: WeekDay) -> some View { weekdayLabel(weekday).frame(maxWidth: .infinity) }
}

// MARK: - Others
public struct WeekdaysView: View {
    
    public init() {}
    
    public var body: some View {
        content()
    }
}
