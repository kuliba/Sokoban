//
//  MonthView.swift
//  
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI

struct MonthView: View {
    
    @Binding var selectedDate: Date?
    @Binding var selectedRange: MDateRange?
    
    let data: Month
    let config: CalendarConfig

    var body: some View {
        
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

private extension MonthView {
    
    func dayView(_ date: Date) -> some View {
        
        config.dayView(
            date,
            isCurrentMonth(date),
            $selectedDate,
            $selectedRange
        ).erased()
    }
}

private extension MonthView {
    
    func isCurrentMonth(_ date: Date) -> Bool { data.month.isSame(.month, as: date) }
}

// MARK: - Others
private extension MonthView {
    
    var animation: Animation { .spring(response: 0.32, dampingFraction: 1, blendDuration: 0) }
}

public protocol MonthLabel: View {
    // MARK: Required Attributes
    var month: Date { get }

    // MARK: View Customisation
    func content() -> AnyView
}

// MARK: - Default View Implementation
public extension MonthLabel {
    func content() -> AnyView { defaultContent().erased() }
}
private extension MonthLabel {
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
    func getString(format: String) -> String { MDateFormatter.getString(from: month, format: format) }
}

// MARK: - Others
public extension MonthLabel {
    var body: some View { content() }
}

public protocol WeekdayLabel: View {
    // MARK: Required Attributes
    var weekday: WeekDay { get }

    // MARK: View Customisation
    func content() -> AnyView
}

// MARK: - Default View Implementation
public extension WeekdayLabel {
    func content() -> AnyView { defaultContent().erased() }
}
private extension WeekdayLabel {
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
    func erased() -> AnyWeekdayLabel { .init(self) }
}

// MARK: - Others
public extension WeekdayLabel {
    var body: some View { content() }
}

public protocol WeekdaysView: View {
    // MARK: View Customisation
    func content() -> AnyView
    func weekdayLabel(_ weekday: WeekDay) -> AnyWeekdayLabel
}

// MARK: - Default View Implementation
public extension WeekdaysView {
    func content() -> AnyView { weekdaysView().erased() }
    func weekdayLabel(_ weekday: WeekDay) -> AnyWeekdayLabel { defaultWeekDayLabel(weekday).erased() }
}
private extension WeekdaysView {
    func defaultWeekDayLabel(_ weekday: WeekDay) -> DefaultWeekdayLabel { DefaultWeekdayLabel(weekday: weekday) }
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
public extension WeekdaysView {
    var body: some View { content() }
}
