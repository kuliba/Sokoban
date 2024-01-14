//
//  ConsentList.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

struct ConsentList: Equatable {
    
    var banks: [SelectableBank]
    let consent: Consent
    var mode: Mode
    var searchText: String
    
    struct SelectableBank: Equatable, Identifiable {
        
        let bank: Bank
        var isSelected: Bool
        
        var id: Bank.ID { bank.id }
    }
    
    typealias Consent = Set<Bank.ID>
    
    enum Mode: Equatable {
        
        case collapsed, expanded
    }
}
