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
    
    //FIXME: rename iso8601
    static let utc: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        //FIXME: TimeZone UTC
        
        return formatter
    }()
    
    
    static let dateAndTime: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        return formatter
    }()
}
