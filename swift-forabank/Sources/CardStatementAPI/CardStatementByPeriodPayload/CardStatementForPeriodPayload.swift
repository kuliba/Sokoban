//
//  CardStatementForPeriodPayload.swift
//  
//
//  Created by Andryusina Nataly on 23.01.2024.
//

import Foundation
import Tagged

public struct CardStatementForPeriodPayload: Equatable {
    
    public let id: ProductID
    public let name: Name?
    public let period: Period
    public let statementFormat: StatementFormat?
    public let cardNumber: CardNumber?
    
    public typealias ProductID = Tagged<_ProductID, Int>
    public enum _ProductID {}
    
    public typealias Name = Tagged<_Name, String>
    public enum _Name {}
    
    public typealias CardNumber = Tagged<_CardNumber, String>
    public enum _CardNumber {}
    
    public init(id: ProductID, name: Name?, period: Period, statementFormat: StatementFormat?, cardNumber: CardNumber?) {
        self.id = id
        self.name = name
        self.period = period
        self.statementFormat = statementFormat
        self.cardNumber = cardNumber
    }
}

extension CardStatementForPeriodPayload {
    
    public struct Period: Equatable {
        
        public let start: Date
        public let end: Date
        
        public init(start: Date, end: Date) {
            self.start = start
            self.end = end
        }
    }
}

extension CardStatementForPeriodPayload {
    
    public enum StatementFormat: String {
        
        case csv = "CSV"
        case pdf = "PDF"
    }
}

public extension CardStatementForPeriodPayload {
    
    var httpBody: Data {
      
        get throws {
            
            let formatter = DateFormatterISO8601()
            
            let startDateFormattedString = formatter.string(from: period.start)
            let endDateFormattedString = formatter.string(from: period.end)
            
            var parameters: [String: Any] = [
                "id": id.rawValue,
                "startDate": startDateFormattedString,
                "endDate": endDateFormattedString
            ]
            
            let name: [String: String]? = name.map { ["name": $0.rawValue] }
            if let name { parameters = parameters.mergeOnto(target: name) }
            
            let statementFormat: [String: String]? = statementFormat.map { ["statementFormat": $0.rawValue] }
            if let statementFormat { parameters = parameters.mergeOnto(target: statementFormat) }
            
            let cardNumber: [String: String]? = cardNumber.map { ["cardNumber": $0.rawValue] }
            if let cardNumber { parameters = parameters.mergeOnto(target: cardNumber) }
            
            return try JSONSerialization.data(
                withJSONObject: parameters as [String: Any]
            )
        }
    }
}

private extension Dictionary where Value: Any {
    func mergeOnto(target: [Key: Value]?) -> [Key: Value] {
        guard let target = target else { return self }
        return self.merging(target) { current, _ in current }
    }
}
