//
//  ConsentList.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

struct ConsentList: Equatable {
    
    var banks: [SelectableBank]
    let consent: Set<Bank.ID>
    var mode: Mode
    var searchText: String
    
    enum Mode: Equatable {
        
        case collapsed, expanded
    }
    
    struct SelectableBank: Equatable, Identifiable {
        
        let bank: Bank
        var isSelected: Bool
        
        var id: Bank.ID { bank.id }
    }
}
