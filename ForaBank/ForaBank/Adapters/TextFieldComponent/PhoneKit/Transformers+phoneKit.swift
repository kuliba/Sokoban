//
//  Transformers+phoneKit.swift
//  
//
//  Created by Igor Malyarov on 26.04.2023.
//

import TextFieldComponent

extension Transformers {
    
    static func phoneKit(
        filterSymbols: [Character],
        substitutions: [CountryCodeSubstitution],
        limit: Int? = 18
    ) -> Transform {
        
        phone(
            filterSymbols: filterSymbols,
            substitutions: substitutions,
            format: {
                
                guard !$0.isEmpty else { return $0 }
                
                return PhoneNumberKitWrapper.formatPartial(!$0.hasPrefix("+") ? "+\($0)" : $0)
            },
            limit: limit
        )
    }
}
