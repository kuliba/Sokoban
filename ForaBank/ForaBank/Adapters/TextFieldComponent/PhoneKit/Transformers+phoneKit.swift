//
//  Transformers+phoneKit.swift
//  
//
//  Created by Igor Malyarov on 26.04.2023.
//

import TextFieldComponent

extension Transformers {
    
    static func phoneKit(
        for type: ContactsViewModel.PaymentsType,
        filterSymbols: [Character],
        substitutions: [CountryCodeSubstitution],
        limit: Int? = 18
    ) -> Transform {
        
        phone(
            filterSymbols: filterSymbols,
            substitutions: substitutions,
            format: {
                
                guard !$0.isEmpty else { return $0 }
                
                switch type {
                case .abroad:
                    return PhoneNumberKitWrapper.formatPartial(for: type, "+\($0)")
                default:
                    return PhoneNumberKitWrapper.formatPartial(for: type, $0)
                }
            },
            limit: limit
        )
    }
}
