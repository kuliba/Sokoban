//
//  OperationType.swift
//  ForaBank
//
//  Created by Max Gribov on 22.12.2021.
//

import Foundation

enum OperationType: String, Codable, Hashable, Unknownable {
    
    /// receipt of money to the account
    case credit = "CREDIT" // пополнение - со знаком плюс
    case creditPlan = "CREDIT_PLAN" // пополнение (значок с часами - В обработке) - со знаком плюс
    case creditFict = "CREDIT_FICT" // пополнение (значок с красным крестиком - Отказ) - со знаком плюс
    
    /// debiting money from an account
    case debit = "DEBIT" // списание - со знаком минус
    case debitPlan = "DEBIT_PLAN" // списание (значок с часами - В обработке) - со знаком минус
    case debitFict = "DEBIT_FICT" // списание (значок с красным крестиком - Отказ) - со знаком минус
    
    case open = "OPEN"
    
    // not finance operation transfer account into demand deposit
    case demandDepositFromAccount = "DV"
    
    case unknown
}

