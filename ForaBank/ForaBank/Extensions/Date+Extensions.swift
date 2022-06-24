//
//  Date+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 01.06.2022.
//

import Foundation

extension Date {
    
    var groupDayIndex: Int {
        
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)

        let components = [year, month, day]
        
        var result: Int = 0
        
        for value in components {
            
            result += value
            result = result * 100
        }
        
        return result / 100
    }
    
    var groupMonthIndex: Int {
        
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)

        let components = [year, month]
        
        var result: Int = 0
        
        for value in components {
            
            result += value
            result = result * 100
        }
        
        return result / 100
    }
}

extension Date {
    
    var startOfDay: Date {
        
         return Calendar.current.startOfDay(for: self)
     }
    
    static func getStartOfCurrentMonth(for date: Date) -> Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: date)

        return  calendar.date(from: components)!
    }
    
    static func getStartOfPrevMonth(for date: Date) -> Date {
        
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.month = -1
        let startOfMonthDate = Date.getStartOfCurrentMonth(for: date)
        
        return calendar.date(byAdding: components, to: startOfMonthDate)!
    }
    
    static func getEndOfMonth(for date: Date) -> Date {
        
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.month = 1
        components.second = -1
        let startOfMonthDate = Date.getStartOfCurrentMonth(for: date)
        
        return calendar.date(byAdding: components, to: startOfMonthDate)!
    }
    
    static func getMonthBack(from date: Date) -> Date {
        
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.month = -1

        return calendar.date(byAdding: components, to: date)!
    }
}
