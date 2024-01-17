//
//  ConsentList+ext.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 14.01.2024.
//

public extension ConsentList {
    
    var selectedBanks: [Bank] {
        
        banks.filter(\.isSelected).map(\.bank)
    }
    
    var selectedBankNames: [String] {
        
        selectedBanks.map(\.name)
    }
}
