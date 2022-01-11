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
    
    
}
