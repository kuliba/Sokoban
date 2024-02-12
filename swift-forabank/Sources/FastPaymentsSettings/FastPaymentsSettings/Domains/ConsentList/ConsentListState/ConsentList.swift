//
//  ConsentList.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

import Tagged

public struct ConsentList: Equatable {
    
    public var banks: [SelectableBank]
    public var consent: Consent
    public var mode: Mode
    public var searchText: String
    public var status: Status?
    
    public init(
        banks: [SelectableBank],
        consent: Consent,
        mode: Mode,
        searchText: String,
        status: Status? = nil
    ) {
        self.banks = banks
        self.consent = consent
        self.mode = mode
        self.searchText = searchText
        self.status = status
    }
}

extension ConsentList {
    
    public struct SelectableBank: Equatable, Identifiable {
        
        public let bank: Bank
        public var isSelected: Bool
        
        public var id: Bank.ID { bank.id }
        
        public init(bank: Bank, isSelected: Bool) {
            
            self.bank = bank
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
