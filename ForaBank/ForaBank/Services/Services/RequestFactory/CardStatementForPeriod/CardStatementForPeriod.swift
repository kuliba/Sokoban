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
