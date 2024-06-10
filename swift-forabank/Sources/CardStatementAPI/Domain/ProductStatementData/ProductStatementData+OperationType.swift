//
//  ProductStatementData+OperationType.swift
//
//
//  Created by Andryusina Nataly on 19.01.2024.
//

import Foundation

public extension ProductStatementData {
    
    enum OperationType {
        
        case credit // пополнение - со знаком плюс
        case creditPlan // пополнение (значок с часами - В обработке) - со знаком плюс
        case creditFict // пополнение (значок с красным крестиком - Отказ) - со знаком плюс
        
        case debit // списание - со знаком минус
        case debitPlan // списание (значок с часами - В обработке) - со знаком минус
        case debitFict // списание (значок с красным крестиком - Отказ) - со знаком минус
        
        case open
        
        case demandDepositFromAccount
    }
}
