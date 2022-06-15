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
