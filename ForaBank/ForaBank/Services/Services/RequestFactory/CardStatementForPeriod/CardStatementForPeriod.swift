//
//  CardStatementForPeriod.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 16.01.2024.
//

import Foundation
import Tagged

/// A namespace.
public enum CardStatementForPeriodDomain {}

extension CardStatementForPeriodDomain {
    
    struct Payload: Equatable {
        
        let id: ProductID
        let name: Name?
        let period: Period
        let statementFormat: StatementFormat?
        let cardNumber: CardNumber?
        
        typealias ProductID = Tagged<_ProductID, Int>
        enum _ProductID {}
        
        typealias Name = Tagged<_Name, String>
        enum _Name {}

        typealias CardNumber = Tagged<_CardNumber, String>
        enum _CardNumber {}
    }
}

extension CardStatementForPeriodDomain.Payload {
    
    var json: Data {
        
        get throws {
            
            var parameters: [String: String] = [
                "id": "\(id.rawValue)",
                "startDate": "\(period.start)",
                "endDate": "\(period.end)"
            ]
            
            let name: [String: String]? = name.map { ["name": $0.rawValue] }
            if let name { parameters = parameters.mergeOnto(target: name) }
            
            let statementFormat: [String: String]? = statementFormat.map { ["statementFormat": $0.rawValue] }
            if let statementFormat { parameters = parameters.mergeOnto(target: statementFormat) }

            let cardNumber: [String: String]? = cardNumber.map { ["cardNumber": $0.rawValue] }
            if let cardNumber { parameters = parameters.mergeOnto(target: cardNumber) }
            
            return try JSONSerialization.data(withJSONObject: parameters
             as [String: String])
        }
    }
}

extension Dictionary where Value: Any {
    public func mergeOnto(target: [Key: Value]?) -> [Key: Value] {
        guard let target = target else { return self }
        return self.merging(target) { current, _ in current }
    }
}
