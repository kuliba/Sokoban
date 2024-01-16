//
//  Banks+ext.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

extension Banks {
    
    static func stub(
        all allBanks: [Bank],
        selected: [Bank]
    ) -> Self {
        
        .init(
            allBanks: allBanks,
            selected: .init(selected.map(\.id))
        )
    }
}
