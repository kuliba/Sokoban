//
//  FilterState.swift
//  
//
//  Created by Дмитрий Савушкин on 18.07.2024.
//

import Foundation

public struct FilterState {
    
    public let productId: Int?
    public var calendar: CalendarState
    public var filter: FilterHistoryState
    public let dateFilter: (Date, Date) -> Void
    
    public init(
        productId: Int?,
        calendar: CalendarState,
        filter: FilterHistoryState,
        dateFilter: @escaping (Date, Date) -> Void
    ) {
        self.productId = productId
        self.calendar = calendar
        self.filter = filter
        self.dateFilter = dateFilter
    }
}

public struct FilterHistoryState {
    
    public let title: String
    
    public var selectDates: (lowerDate: Date?, upperDate: Date?)?
    public var selectedPeriod: Period
    public var selectedTransaction: TransactionType?
    public var selectedServices: Set<String>
    
    public let periods: [Period]
    public let transactionType: [TransactionType]
    public var services: [String]
    
    public let historyService: (Date?, Date?) -> Void
    
    public init(
        title: String,
        selectDates: (lowerDate: Date?, upperDate: Date?)?,
        selectedPeriod: Period = .month,
        selectedTransaction: TransactionType? = nil,
        selectedServices: Set<String> = [],
        periods: [Period],
        transactionType: [TransactionType],
        services: [String],
        historyService: @escaping (Date?, Date?) -> Void
    ) {
        self.title = title
        self.selectDates = selectDates
        self.selectedPeriod = selectedPeriod
        self.selectedTransaction = selectedTransaction
        self.selectedServices = selectedServices
        self.periods = periods
        self.transactionType = transactionType
        self.services = services
        self.historyService = historyService
    }
}

public extension FilterHistoryState {
    
    enum TransactionType: String, CaseIterable {
        
        case debit
        case credit
        
        var title: String {
            
            switch self {
            case .debit: "Списание"
            case .credit: "Пополнение"
            }
        }
    }
    
    enum Period: String, Identifiable, CaseIterable {
        
        public var id: String { self.rawValue }
        
        case week = "Неделя"
        case month = "Месяц"
        case dates = "Выбрать период"
    }
}
