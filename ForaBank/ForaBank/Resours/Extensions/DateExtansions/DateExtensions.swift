//
//  DateExtensions.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.09.2021.
//

import Foundation

public let kDefaultDateLocaleIdentifier = "en_US_POSIX"
public let kDefaultDateFormatSimpleDate = "yyyy-MM-dd"
public let kDefaultDateFormatSimpleDateConvenient = "dd.MM.yyyy"
public let kDefaultDateFormatUTC = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
public let kDefaultDateFormatShort = "EEE dd MMM yyyy HH:mm"
public let kDefaultDateFormatShortDate = "EEE dd MMM yyyy"
public let kDefaultDateFormatLongDate = "EEEE, dd MMMM yyyy"
public let kDefaultWeekDayMonthFormat = "EEE, d MMM"
public let kDefaultTimeFormatShort12 = "hh:mm a"
public let kDefaultTimeFormatShort24 = "HH:mm"
public let kDefaultDateFormatDayOnly = "EEE"
public let kDefaultDayOfWeekFormat = "EEEE"
public let kDefaultDayMonthFormat = "d MMM"
public let kDefaultDayMonthWeekdayFormat = "dd.MM EEE"
public let kDefaultMonthYearFormat = "MMMM yyyy"
public let kDefaultMonthFullFormat = "LLLL"
public let kDefaultDayMonthTimeFormat = "dd/MM HH:mm"


extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}


extension Date {
    func localDate() -> Date {
      //  let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else {return Date()}

        return localDate
    }
}


extension Date {
    
    fileprivate static let _calendar: Calendar = {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(identifier: TimeZone.current.identifier)!
        return calendar
    }()
    
    fileprivate static let _dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)!
        return formatter
    }()
    
    fileprivate static let _dateLondonFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Europe/London")!
        return formatter
    }()
    
    fileprivate static let _locale: Locale = Locale.autoupdatingCurrent
    
    static var sharedCalendar: Calendar { return _calendar }
    static var sharedDateFormatter: DateFormatter { return _dateFormatter }
    
    static func defaultDateComponents() -> Set<Calendar.Component> {
        return [.year, .month, .day, .hour, .minute]
    }
    
    static func dateFormatterUTC() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDateFormatUTC
        return _dateFormatter
    }
    
    static func dateFormatterShortDateTime() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDateFormatShort
        return _dateFormatter
    }
    
    static func dateFormatterShortDate() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDateFormatShortDate
        return _dateFormatter
    }
    
    static func dateFormatterDayMonthWeekdayShortDate() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDayMonthWeekdayFormat
        return _dateFormatter
    }
    
    static func dateFormatterSimpleDate() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.timeZone = TimeZone(identifier: "Europe/London")!
        _dateFormatter.dateFormat = kDefaultDateFormatSimpleDate
        return _dateFormatter
    }
    
    static func dateFormatterDateConvenient() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDateFormatSimpleDate
        return _dateFormatter
    }
    
    static func dateFormatterSimpleDateConvenient() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDateFormatSimpleDateConvenient
        return _dateFormatter
    }
    
    static func dateLondonFormatterSimpleDate() -> DateFormatter {
        _dateLondonFormatter.locale = _locale
        _dateLondonFormatter.dateFormat = kDefaultDateFormatSimpleDate
        return _dateLondonFormatter
    }
    
    static func dateFormatterLongDate() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDateFormatLongDate
        return _dateFormatter
    }
    
    static func dateFormatterDayMonthDate() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDayMonthFormat
        return _dateFormatter
    }
    
    static func dateFormatterWeekDayMonthDate() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultWeekDayMonthFormat
        return _dateFormatter
    }
    
    static func dateFormatterTime() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = nil
        _dateFormatter.dateStyle = .none
        _dateFormatter.timeStyle = .short
        return _dateFormatter
    }
    
    static func dateFormatterShortTime() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultTimeFormatShort12
        return _dateFormatter
    }
    
    static func dateFormatterShortTime24() -> DateFormatter {
        _dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        _dateFormatter.dateFormat = kDefaultTimeFormatShort24
        return _dateFormatter
    }
    
    static func dateFormatterDayOfWeek() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDateFormatDayOnly
        return _dateFormatter
    }
    
    static func dateFormatterWeekday() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDayOfWeekFormat
        return _dateFormatter
    }
    
    static func dateFormatterMonthYear() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultMonthYearFormat
        return _dateFormatter
    }
    
    static func dateFormatterMonthFull() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultMonthFullFormat
        return _dateFormatter
    }
    
    static func dateFormatterDayMonthTime() -> DateFormatter {
        _dateFormatter.locale = _locale
        _dateFormatter.dateFormat = kDefaultDayMonthTimeFormat
        return _dateFormatter
    }
    
    // MARK: NSDate Utilities
    static func dateWithoutTime(_ timeStamp: Date?) -> Date {
        let timeStampDate = timeStamp ?? Date()
        
        let comps = _calendar.dateComponents([.year, .month, .day], from: timeStampDate as Date)
        return _calendar.date(from: comps)!
    }
    
    static func timeWithoutDate(_ timeStamp: Date?) -> Date {
        let timeOnly = timeStamp ?? Date()
        let comps = _calendar.dateComponents([.hour, .minute, .second], from: timeOnly)
        return _calendar.date(from: comps)!
    }
    
    static func dateWithDays(_ days: NSInteger, fromDate date: Date) -> Date {
        let timeIntervalForDays = Double(days * 24 * 3600)
        return date.addingTimeInterval(timeIntervalForDays)
    }
    
    static func dateComponentsFromDate(_ date: Date) -> DateComponents {
        let unitFlags: Set<Calendar.Component> = [.year, .month, .weekOfMonth, .weekday, .weekdayOrdinal, .day, .hour, .minute, .second]
        let userCalendar = _calendar
        let dateComponents = userCalendar.dateComponents(unitFlags, from: date)
        
        return dateComponents
    }
    
    static func amountOfYearsBetween(_ first: Date, and second: Date) -> Int {
        let firstYear = dateComponentsFromDate(first).year!
        let secondYear = dateComponentsFromDate(second).year!
        
        return secondYear - firstYear
    }
    
    // MARK: Parsing from date
    static func dateFromEpochTime(_ epochTime: NSNumber?) -> Date? {
        var date: Date?
        if let seconds = epochTime?.doubleValue {
            date = Date(timeIntervalSince1970: seconds)
        }
        return date ?? nil
    }
    
    static func dateFromMillisecondEpochTime(_ epochTime: NSNumber?) -> Date? {
        var date: Date?
        if var seconds = epochTime?.doubleValue {
            seconds = seconds / 1000
            date = Date(timeIntervalSince1970: seconds)
        }
        return date ?? nil
    }
    
    static func dateFromString(_ stringDate: String) -> Date? {
        return dateFormatterUTC().date(from: stringDate)
    }
    
    static func dateFromShortString(_ stringDate: String) -> Date? {
        return dateFormatterShortDate().date(from: stringDate)
    }
    
    static func dateFromSimpleString(_ stringDate: String) -> Date? {
        return dateFormatterSimpleDate().date(from: stringDate)
    }
    
    static func dateLondonFromSimpleString(_ stringDate: String) -> Date? {
        return dateLondonFormatterSimpleDate().date(from: stringDate)
    }
    
    static func timeFromString(_ stringTime: String) -> Date? {
        let dateFormatter = dateFormatterShortTime()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: stringTime)
    }
    
    // MARK: date formatting
    static func stringFromEpochTimeDate(_ epochTime: Date) -> String {
        return String(format: "%f", epochTime.timeIntervalSince1970)
    }
    
    static func millisecondEpochTimeStringFromDate(_ date: Date) -> String {
        return String(format:"%f", date.timeIntervalSince1970 * 1000)
    }
    
    static func stringFromDate(_ date: Date) -> String {
        return dateFormatterUTC().string(from: date)
    }
    
    static func shortStringFromDate(_ date: Date) -> String {
        return dateFormatterShortDateTime().string(from: date)
    }
    
    static func shortDateStringFromDate(_ date: Date) -> String {
        return dateFormatterShortDate().string(from: date)
    }
    
    static func weekDayMonthFromDate(_ date: Date) -> String {
        return dateFormatterWeekDayMonthDate().string(from: date)
    }
    
    static func shortDayMonthWeekdayFromDate(_ date: Date) -> String {
        return dateFormatterDayMonthWeekdayShortDate().string(from: date)
    }
    
    static func longDateStringFromDate(_ date: Date) -> String {
        return dateFormatterLongDate().string(from: date)
    }
    
    static func stringTimeFromDate(_ date: Date) -> String {
        return dateFormatterTime().string(from: date)
    }
    
    static func stringFromShortTime(_ date: Date) -> String {
        return dateFormatterShortTime().string(from: date)
    }
    
    static func stringFromShortTime24(_ date: Date) -> String {
        return dateFormatterShortTime24().string(from: date)
    }
    
    static func stringFromDateDayMonth(_ date: Date) -> String {
        return dateFormatterDayMonthDate().string(from: date)
    }
    
    static func stringFromWeekDateDayMonth(_ date: Date) -> String {
        return dateFormatterWeekDayMonthDate().string(from: date)
    }
    
    static func stringWeekdayFromDate(_ date: Date) -> String {
        return dateFormatterWeekday().string(from: date)
    }
    
    static func stringMonthYearFromDate(_ date: Date) -> String {
        return dateFormatterMonthYear().string(from: date)
    }
    
    static func stringMonthFullFromDate(_ date: Date) -> String {
        return dateFormatterMonthFull().string(from: date)
    }
    
    static func stringSimpleFromDate(_ date: Date) -> String {
        return dateFormatterSimpleDate().string(from: date)
    }
    
    static func stringSimpleConvenientFromDate(_ date: Date) -> String {
        return dateFormatterSimpleDateConvenient().string(from: date)
    }
    
    static func stringDayMonthTimeFromDate(_ date: Date) -> String {
        return dateFormatterDayMonthTime().string(from: date)
    }
    
    // MARK: Adding
    static func date(_ date: Date, addTime time: Date) -> Date? {
        let fixedTime = Date.timeWithoutDate(time)
        let unitFlags: Set<Calendar.Component> = [.hour, .minute, .second]
        let components = Calendar.current.dateComponents(unitFlags, from: fixedTime)
        var seconds: Int = components.hour! * 3600
        seconds += components.minute! * 60
        seconds += components.second!
        return Date.date(date, addSeconds: seconds)
    }
    
    static func date(_ date: Date, addYears amount: Int) -> Date? {
        return Date.date(date, addCalendarComponents: .year, amount: amount)
    }
    
    static func date(_ date: Date, addMonths amount: Int) -> Date? {
        return Date.date(date, addCalendarComponents: .month, amount: amount)
    }
    
    static func date(_ date: Date, addWeeks amount: Int) -> Date? {
        return Date.date(date, addCalendarComponents: .weekOfYear, amount: amount)
    }
    
    static func date(_ date: Date, addDays amount: Int) -> Date? {
        return Date.date(date, addCalendarComponents: .day, amount: amount)
    }
    
    static func date(_ date: Date, addSeconds amount: Int) -> Date? {
        return Date.date(date, addCalendarComponents: .second, amount: amount)
        
    }
    
    static func date(_ date: Date, addCalendarComponents calendarComponents: Calendar.Component, amount: Int) -> Date? {
        var components: DateComponents = DateComponents.init()
        let gregorian: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        switch calendarComponents {
        case .second:
            components.second = amount
            break
        case .minute:
            components.minute = amount
            break
        case .hour:
            components.hour = amount
            break
        case .day:
            components.day = amount
            break
        case .weekOfMonth:
            components.weekOfMonth = amount
            break
        case .month:
            components.month = amount
            break
        case .year:
            components.year = amount
            break
        default:
            break
        }
        return gregorian.date(byAdding: components, to: date)
    }
    
    
    // MARK: Compare
    func withinNextHour() -> Bool { return timeIntervalSinceNow < 60 * 60 && timeIntervalSinceNow > Date().timeIntervalSinceNow }
    
    func isToday() -> Bool {
        return Date.sharedCalendar.isDateInToday(self)
    }
    
    func isTomorrow() -> Bool {
        return Date.date(self, addDays: -1)?.isToday() ?? false
    }
    
    func isInTheFuture() -> Bool {
        return self.isLaterThan(Date())
    }
    
    func isInThePast() -> Bool {
        return self.isEarlierThan(Date())
    }
    
    func isEarlierThan(_ date: Date) -> Bool {
        return (self.compare(date as Date) == .orderedAscending)
    }
    
    func isLaterThan(_ date: Date) -> Bool {
        return (self.compare(date as Date) == .orderedDescending)
    }
    
    func isBetweenStartDate(_ a: Date, endDateInclusive b: Date) -> Bool {
        var start: Date
        var end: Date
        if b.isEarlierThan(a) {
            start = b
            end = a
        } else {
            start = a
            end = b
        }
        let minimumDateInterval: TimeInterval = start.timeIntervalSince1970
        let maximumDateInterval: TimeInterval = end.timeIntervalSince1970
        let receiverInterval: TimeInterval = self.timeIntervalSince1970
        return (receiverInterval >= minimumDateInterval&&receiverInterval <= maximumDateInterval)
    }
    
    func isTheSameDay(as date: Date) -> Bool {
        return Date._calendar.compare(self, to: date, toGranularity: .day) == .orderedSame
    }
    
    func isTheSameMonth(as date: Date) -> Bool {
        return Date._calendar.compare(self, to: date, toGranularity: .month) == .orderedSame
    }
    
    func dateToNearestMinutes(_ minutes: Int) -> Date? {
        let unitFlags: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .weekOfMonth,
            .hour,
            .minute,
            .second,
            .weekday,
            .weekdayOrdinal
        ]
        var comps = Calendar.current.dateComponents(unitFlags, from: self)
        let roundedMinutes = abs(TRBMath.RoundUp(Float(comps.minute!), interval: Float(minutes)))
        comps.minute = Int(roundedMinutes)
        comps.second = 0
        return Calendar.current.date(from: comps)
    }
    
    static func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
        let components = _calendar.dateComponents([.day], from: startDate, to: endDate)
        
        return components.day ?? 0
    }
    
    func daysFromNow() -> Int {
        return Date.daysBetweenDates(startDate: Date(), endDate: self)
    }
    
    static func combineDate(_ date: Date, withTime time: Date) -> Date? {
        let sessionDateComponents: DateComponents = _calendar.dateComponents([.year, .month, .day], from: date)
        let sessionTimeComponents: DateComponents = _calendar.dateComponents([.hour, .minute], from: time)
        
        var combinedComponents: DateComponents = DateComponents.init()
        combinedComponents.year = sessionDateComponents.year
        combinedComponents.month = sessionDateComponents.month
        combinedComponents.day = sessionDateComponents.day
        combinedComponents.hour = sessionTimeComponents.hour
        combinedComponents.minute = sessionTimeComponents.minute
        
        return _calendar.date(from: combinedComponents)
    }
    
    static func is12Hour() -> Bool {
        let formatString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        let hasAMPM = formatString.contains("a")
        return hasAMPM
    }
    
}

@objc open class TRBMath: NSObject {
    open class func RoundTo(_ number: Float, interval: Float) -> Float {
        if number >= 0 {
            return interval * floorf(number / interval + 0.5)
        } else {
            return interval * ceilf(number / interval - 0.5)
        }
    }
    
    open class func RoundUp(_ number: Float, interval: Float) -> Float {
        if number >= 0 {
            return interval * ceilf(number / interval)
        } else {
            return interval * floorf(number / interval)
        }
    }
}
