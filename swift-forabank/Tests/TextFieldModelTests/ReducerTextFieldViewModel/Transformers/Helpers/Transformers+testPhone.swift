//
//  Transformers+testPhone.swift
//  
//
//  Created by Igor Malyarov on 22.05.2023.
//

import TextFieldModel

extension Transformers {
    
    static let testPhone = Transformers.phone(
        filterSymbols: ["-", "(", ")"], // or []
        substitutions: .test,
        format: {
            guard !$0.isEmpty else { return "" }
            
            return "+\($0)"
        },
        limit: 6
    )
    
    static let filteringTestPhone = Transformers.phone(
        filterSymbols: .defaultFilterSymbols,
        substitutions: .test,
        format: {
            guard !$0.isEmpty else { return "" }
            
            return "+\($0)"
        },
        limit: 6
    )
}

extension [Character] {
    
    static let defaultFilterSymbols: [Character] = ["-", "(", ")", "+"]
    
}
