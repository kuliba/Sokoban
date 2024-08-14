//
//  FilterState.swift
//  
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation

public struct FilterState {
    
    let title: String
    
    public var selectedPeriod: Period
    public var selectedTransaction: TransactionType?
    public var selectedServices: Set<String>
    
    let periods: [Period]
    let transactionType: [TransactionType]
    public var services: [String]
    
    public init(
        title: String,
        selectedPeriod: Period = .month,
        selectedTransaction: TransactionType? = nil,
        selectedServices: Set<String> = [],
        periods: [Period],
        transactionType: [TransactionType],
        services: [String]
    ) {
        self.title = title
        self.selectedPeriod = selectedPeriod
        self.selectedTransaction = selectedTransaction
        self.selectedServices = selectedServices
        self.periods = periods
        self.transactionType = transactionType
        self.services = services
    }
}

public extension FilterState {
    
    enum TransactionType: String, Identifiable, CaseIterable {
        
        public var id: String { self.rawValue }
        
        case debit = "Списание"
        case credit = "Пополнение"
    }
    
    enum Period: String, Identifiable, CaseIterable {
        
        public var id: String { self.rawValue }
        
        case week = "Неделя"
        case month = "Месяц"
        case dates = "Выбрать период"
    }
}
