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
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "ru_RU")
  
        return formatter
    }

    static var shortDate: DateFormatter {

        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.long

        dateFormatter.dateFormat =  "dd.MM.yy"
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "ru_RU")

        return dateFormatter
    }
    
    static let iso8601: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        return formatter
    }()
    
    
    static let dateAndTime: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        return formatter
    }()
    
    static let dateAndMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        
        return formatter
    }()
    
    
    static let historyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat =  "d MMMM, E"
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "ru_RU")
        
        return formatter
    }()
}
