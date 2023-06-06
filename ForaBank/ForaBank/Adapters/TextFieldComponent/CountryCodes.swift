//
//  CountryCodes.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.05.2023.
//

import TextFieldComponent

extension CountryCodeReplace {
    
    var substitution: CountryCodeSubstitution {
        
        .init(from: .init(from), to: to)
    }
}

extension Array where Element == CountryCodeSubstitution {
    
    static let russian: Self = [CountryCodeReplace]
        .russian
        .map(\.substitution)
    
    static let armenian: Self = [CountryCodeReplace]
        .armenian
        .map(\.substitution)
    
    static let turkish: Self = [CountryCodeReplace]
        .turkey
        .map(\.substitution)
}
