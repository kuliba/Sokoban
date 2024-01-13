//
//  ConsentListState.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 13.01.2024.
//

enum ConsentListState: Equatable {
    
    case collapsed(Collapsed)
    case expanded(Expanded)
    case collapsedError
    case expandedError
}

extension ConsentListState {
    
    struct Collapsed: Equatable {
        
        let bankNames: [String]
    }
    
    struct Expanded: Equatable {
        
        let searchText: String
        var banks: [SelectableBank]
        
        struct SelectableBank: Equatable, Identifiable {
            
            let bank: Bank
            var isSelected: Bool
            
            var id: Bank.ID { bank.id }
            var name: String { bank.name }
        }
    }
}
