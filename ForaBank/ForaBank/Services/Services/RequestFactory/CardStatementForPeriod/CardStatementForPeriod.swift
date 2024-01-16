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
        
        let productID: ProductID
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
            
            var parameters: [[String: Any]] = [[
                "id": "\(productID)"
            ],[
                "startDate": period.start,
                "endDate": period.end
            ]]
            
            let name: [[String: String]]? = name.map { [[
                "name": $0.rawValue
            ]] }
            if let name { parameters.append(contentsOf: name) }
            
            let statementFormat: [[String: String]]? = statementFormat.map { [[
                "statementFormat": $0.rawValue
            ]] }
            if let statementFormat { parameters.append(contentsOf: statementFormat) }

            let cardNumber: [[String: String]]? = cardNumber.map { [[
                "cardNumber": $0.rawValue
            ]] }
            if let cardNumber { parameters.append(contentsOf: cardNumber) }

            return try JSONSerialization.data(withJSONObject: [
                "parameters": parameters
            ] as [String: [[String: Any]]])
        }
    }
}
