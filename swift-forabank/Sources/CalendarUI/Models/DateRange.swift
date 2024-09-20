//
//  DateRange.swift
//
//
//  Created by Дмитрий Савушкин on 22.05.2024.
//

import Foundation

public class MDateRange: ObservableObject {
    
    @Published public var lowerDate: Date?
    @Published public var upperDate: Date?

    init(_ lowerDate: Date?, _ upperDate: Date?) {
        
        self.lowerDate = lowerDate
        self.upperDate = upperDate
    }
    
    convenience public init(range: Range<Date>) {
        
        self.init(startDate: range.lowerBound, endDate: range.upperBound)
    }
}

// MARK: - Updating Range
extension MDateRange {
    
    func _addToRange(_ date: Date) {
        
        if lowerDate == nil { setLowerDate(date) }
        else if upperDate == nil { setUpperDate(date) }
        else { updateExistedRange(date) }
    }
}

extension MDateRange {
    
    func setLowerDate(_ date: Date) {
        if let upperDate, date <= upperDate {
            lowerDate = date
        } else if upperDate == nil {
            lowerDate = date
        }
    }
    
    func setUpperDate(_ date: Date) {
        if let lowerDate, date >= lowerDate { upperDate = date }
        else if let lowerDate { 
            upperDate = lowerDate
            self.lowerDate = date
        }
    }
    
    func updateExistedRange(_ date: Date) {
        lowerDate = date
        upperDate = nil
    }
}

// MARK: - Getting Range
extension MDateRange {
    
    func _getRange() -> ClosedRange<Date>? {
        if let lowerDate {
            return .init(uncheckedBounds: (lowerDate, upperDate ?? lowerDate))
        }
        return nil
    }
}

// MARK: - Others
public extension MDateRange {
    
    func contains(_ date: Date) -> Bool {
        getRange()?.contains(date) == true
    }
    func isRangeCompleted() -> Bool { upperDate != nil }
}

public extension MDateRange {
    convenience init(startDate: Date? = nil, endDate: Date? = nil) { self.init(startDate, endDate) }
}

// MARK: - Updating Range
public extension MDateRange {
    func addToRange(_ date: Date) {
        _addToRange(date)
    }
}

// MARK: - Getting Range
public extension MDateRange {
    func getRange() -> ClosedRange<Date>? { _getRange() }
}

public extension MDateRange {
    
    var rangeSelected: Bool {
        
        ((self.getRange()?.upperBound) != nil)
    }
}
