//
//  ConsentList.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Tagged

public struct ConsentList: Equatable {
    
    public var banks: [SelectableBank]
    public var mode: Mode
    public var searchText: String
    public var status: Status?
    
    public init(
        banks: [SelectableBank],
        mode: Mode = .collapsed,
        searchText: String = "",
        status: Status? = nil
    ) {
        self.banks = banks
        self.mode = mode
        self.searchText = searchText
        self.status = status
    }
}

extension ConsentList {
    
    public struct SelectableBank: Equatable, Identifiable {
        
        public let bank: Bank
        public let isConsented: Bool
        public var isSelected: Bool
        
        public var id: Bank.ID { bank.id }
        
        public init(
            bank: Bank,
            isConsented: Bool,
            isSelected: Bool
        ) {
            self.bank = bank
            self.isConsented = isConsented
            self.isSelected = isSelected
        }
    }
    
    public enum Mode: Equatable {
        
        case collapsed, expanded
    }
    
    public enum Status: Equatable {
        
        case failure(ServiceFailure)
        case inflight
    }
}

public extension Array where Element == ConsentList.SelectableBank {
    
    init(banks: [Bank], consent: Consent) {
        
        self.init(banks: banks, consent: consent, select: consent)
    }
    
    typealias Select = Set<Bank.BankID>
    
    init(banks: [Bank], consent: Consent, select: Select) {
        
        self = banks
            .map {
                
                let isConsented = consent.contains($0.id)
                let isSelected = select.contains($0.id)
                
                return .init(
                    bank: $0,
                    isConsented: isConsented,
                    isSelected: isSelected
                )
            }
            .sorted() // Comparable!!
    }
}
