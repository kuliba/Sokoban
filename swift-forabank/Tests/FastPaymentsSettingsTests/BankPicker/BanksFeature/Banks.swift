//
//  Banks.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import FastPaymentsSettings
import Tagged

public struct Banks: Equatable {
    
    public let allBanks: [Bank]
    public let selected: Set<Bank.ID>
    
    public init(allBanks: [Bank], selected: Set<Bank.ID>) {
        
        self.allBanks = allBanks
        self.selected = selected
    }
}

public struct SelectableBank: Equatable {
    
    public let bank: Bank
    public let isSelected: Bool
    
    public init(bank: Bank, isSelected: Bool) {
     
        self.bank = bank
        self.isSelected = isSelected
    }
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
