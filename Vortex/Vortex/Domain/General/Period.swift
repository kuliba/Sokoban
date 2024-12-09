//
//  Period.swift
//  Vortex
//
//  Created by Max Gribov on 08.06.2022.
//

import Foundation

struct Period: Codable, Equatable {

    let start: Date
    let end: Date
    
    init(start: Date, end: Date) { //MARK: init with Calendar
        
        self.start = start
        self.end = end
    }
    
    init(daysBack: Int, from referenceDate: Date) {
        
        self.start = referenceDate.advanced(by: -TimeInterval.value(days: daysBack))
        self.end = referenceDate
    }
}

extension Period {
    
    var range: ClosedRange<Date> {
        start...end //MARK: end - start of next day time
    }
}
extension Period {
    
    func including(_ other: Period) -> Period {
        
        Period(start: min(start, other.start), end: max(end, other.end))
    }
}


extension Period: CustomDebugStringConvertible {
    
    var debugDescription: String {
        
        "period start: \(start), end: \(end)"
    }
}

//MARK: - Types

extension Period {
    
    enum Direction: CustomDebugStringConvertible {
        
        case latest
        case eldest
        case custom(start: Date, end: Date)
        
        var debugDescription: String {
            
            switch self {
            case .latest: return "direction: latest"
            case .eldest: return "direction: eldest"
            case .custom: return "direction: custom"
            }
        }
    }
}
