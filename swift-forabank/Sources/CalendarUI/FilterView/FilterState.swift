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
    public var isLoading: Bool

    public init(
        productId: Int?,
        calendar: CalendarState,
        filter: FilterHistoryState,
        isLoading: Bool = false
    ) {
        self.productId = productId
        self.calendar = calendar
        self.filter = filter
        self.isLoading = isLoading
    }
}

public struct FilterHistoryState {
    
    public let title: String
    
    public var selectDates: (lowerDate: Date?, upperDate: Date?)? //TODO: replace with optional range
    public var selectedPeriod: Period
    public var selectedTransaction: TransactionType?
    public var selectedServices: Set<String>
    
    public let periods: [Period]
    public let transactionType: [TransactionType]
    public var services: [String]
        
    public init(
        title: String,
        selectDates: (lowerDate: Date?, upperDate: Date?)?,
        selectedPeriod: Period = .month,
        selectedTransaction: TransactionType? = nil,
        selectedServices: Set<String> = [],
        periods: [Period],
        transactionType: [TransactionType],
        services: [String]
    ) {
        self.title = title
        self.selectDates = selectDates
        self.selectedPeriod = selectedPeriod
        self.selectedTransaction = selectedTransaction
        self.selectedServices = selectedServices
        self.periods = periods
        self.transactionType = transactionType
        self.services = services
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

extension FilterState {
    
    public static let preview: Self = .init(
        productId: 0,
        calendar: .preview,
        filter: .preview
    )
}

extension FilterHistoryState {

    static let preview: Self = .init(
        title: "Фильтры",
        selectDates: (nil, nil),
        periods: [],
        transactionType: [],
        services: []
    )
}

extension CalendarState {
    
    static let preview: Self = .init(
        date: nil,
        range: .init(),
        monthsData: [],
        periods: []
    )
}
