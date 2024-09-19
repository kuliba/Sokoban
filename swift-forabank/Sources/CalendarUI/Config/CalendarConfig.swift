//
//  CalendarConfig.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import SwiftUI
import SharedConfigs

// MARK: - Internal
//TODO: fix `CalendarConfig` to normal config, remove any
public struct CalendarConfig {
    
    public let title: String //FIX: remove title 
    public let titleConfig: TextConfig //FIX: remove title
    public let option: TextConfig
    let month: TextConfig
    let optionSelectBackground: Color
    let monthLabelDaysSpacing: CGFloat = 12
    let monthsPadding: (top: CGFloat, bottom: CGFloat) = (12, 24)
    var monthsSpacing: CGFloat = 24
    let daysSpacing: (vertical: CGFloat, horizontal: CGFloat) = (2, 0)

    var monthsViewBackground: Color = .clear

    var weekdaysView: () -> WeekdaysView
    var monthLabel: (Date) -> MonthLabel

    var scrollDate: Date? = nil
    var onMonthChange: (Date) -> () = {_ in}
    
    let dayConfig: DayConfig
    let closeImage: Image
    
    public init(
        title: String,
        titleConfig: TextConfig,
        option: TextConfig,
        month: TextConfig,
        optionSelectBackground: Color,
        monthsSpacing: CGFloat = 24,
        monthsViewBackground: Color = .clear,
        weekdaysView: @escaping () -> WeekdaysView,
        monthLabel: @escaping (Date) -> MonthLabel,
        dayConfig: DayConfig,
        closeImage: Image,
        scrollDate: Date? = nil,
        onMonthChange: @escaping (Date) -> () = {_ in}
    ) {
        self.title = title
        self.titleConfig = titleConfig
        self.option = option
        self.month = month
        self.optionSelectBackground = optionSelectBackground
        self.monthsSpacing = monthsSpacing
        self.monthsViewBackground = monthsViewBackground
        self.weekdaysView = weekdaysView
        self.monthLabel = monthLabel
        self.dayConfig = dayConfig
        self.closeImage = closeImage
        self.scrollDate = scrollDate
        self.onMonthChange = onMonthChange
    }
}

//// MARK: - Distances Between Objects
//public extension CalendarConfig {
//
//    /// Sets the spacing between months in the view.
//    func monthsSpacing(_ value: CGFloat) -> Self {
//        changing(path: \.monthsSpacing, to: value)
//    }
//}
//
//// MARK: - View Customisation
//public extension CalendarConfig {
//    /// Sets the background for the months view.
//    func monthsViewBackground(_ value: Color) -> Self {
//        changing(path: \.monthsViewBackground, to: value)
//    }
//}
//
//// MARK: - Custom Views
//public extension CalendarConfig {
//    /// Replaces the default weekdays view with a selected implementation.
//    func weekdaysView(_ builder: @escaping () -> WeekdaysView) -> Self {
//        changing(path: \.weekdaysView, to: builder)
//    }
//
//    /// Replaces the default month label with a selected implementation.
//    func monthLabel(_ builder: @escaping (Date) -> MonthLabel) -> Self {
//        changing(path: \.monthLabel, to: builder)
//    }
//
//    /// Replaces the default day view with a selected implementation.
//    func dayView(_ builder: @escaping (Date, Bool, Date?, MDateRange?, @escaping (Date) -> Void) -> DayView) -> Self {
//        changing(path: \.dayView, to: builder)
//    }
//}
//
//// MARK: - Modifiers
//public extension CalendarConfig {
//    /// Scrolls the calendar to the selected date.
//    func scrollTo(date: Date?) -> Self {
//        changing(path: \.scrollDate, to: date)
//    }
//
//    /// Triggers when a new month is about to be visible.
//    func onMonthChange(_ value: @escaping (Date) -> ()) -> Self {
//        changing(path: \.onMonthChange, to: value)
//    }
//}
