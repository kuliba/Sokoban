//
//  DateFormatter+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

extension DateFormatter {
    
    static var operation: DateFormatter {
        
        let formatter = DateFormatter()
        formatter.timeStyle = DateFormatter.Style.short//Set time style
        formatter.dateStyle = DateFormatter.Style.long //Set date style
        
//        formatter.dateFormat =  "d MMMM, E"
        formatter.locale = Locale(identifier: "ru_RU")
  
        return formatter
    }

    static var shortDate: DateFormatter {

        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.long

        dateFormatter.dateFormat =  "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        return dateFormatter
    }
    
    static var shortDateGTM0: DateFormatter {

        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        dateFormatter.dateFormat =  "dd.MM.yy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        return dateFormatter
    }
    
    static var closeDepositDate: DateFormatter {

        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.long

        dateFormatter.dateFormat =  "dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")

        return dateFormatter
    }
    
    static let iso8601: DateFormatter = DateFormatterISO8601()
    
    static let minutsAndSecond: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        return formatter
    }()
    
    
    static let dateAndTime: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        return formatter
    }()
    
    static let dateAndMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        
        return formatter
    }()
    
    static let timeAndSecond: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "HH:mm"
        
        return formatter
    }()
    
    static let historyShortDateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, E"
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }()
    
    static let historyFullDateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }()
    
    static let historyDateAndTimeFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }()
    
    static let detailFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat =  "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }()
    
    static let moscowTimeRuFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")!
        
        return formatter
    }()
    
    static let loanProductPeriod: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/YY"
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }()
    
    static let monthFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }()
}

class DateFormatterISO8601: DateFormatter {
    
    private let formatter: ISO8601DateFormatter
    
    override init() {
        self.formatter = ISO8601DateFormatter()
        super.init()
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withFractionalSeconds, .withTimeZone]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func date(from string: String) -> Date? {
        
        formatter.date(from: string)
    }
    
    override func string(from date: Date) -> String {
        
        formatter.string(from: date)
    }
}
