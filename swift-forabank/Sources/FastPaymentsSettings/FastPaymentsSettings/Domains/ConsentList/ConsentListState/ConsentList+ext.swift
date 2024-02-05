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

public extension ConsentList {
    #warning("add tests")
    init(
        _ banks: [Bank],
        consent: Consent,
        mode: Mode = .collapsed,
        searchText: String = "",
        status: Status? = nil
    ) {
        self.init(
            banks: banks.select(consent: consent),
            consent: consent,
            mode: mode,
            searchText: searchText,
            status: status
        )
    }
}

private extension Array where Element == Bank {
    
    func select(
        consent: Consent
    ) -> [ConsentList.SelectableBank] {
    
        map { .init(bank: $0, isSelected: consent.contains($0.id)) }
    }
}
