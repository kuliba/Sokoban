//
//  Banks.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import Tagged

struct Banks: Equatable {
    
    let allBanks: [Bank]
    let selected: Set<Bank.ID>
}

struct Bank: Equatable, Identifiable {
    
    let id: ID
    let name: String
    
    typealias ID = Tagged<_ID, String>
    enum _ID {}
}

struct SelectableBank: Equatable {
    
    let bank: Bank
    let isSelected: Bool
}

extension Banks {
    
    var withSelection: [SelectableBank] {
        
        let selected = allBanks
            .filter { self.selected.contains($0.id) }
            .sorted(by: \.name)
            .map { SelectableBank(bank: $0, isSelected: true) }
        
        let unselected = allBanks
            .filter { !self.selected.contains($0.id) }
            .sorted(by: \.name)
            .map { SelectableBank(bank: $0, isSelected: false) }
        
        return selected + unselected
    }
}
