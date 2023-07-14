//
//  RegexTransformer+ext.swift
//  
//
//  Created by Igor Malyarov on 18.05.2023.
//

public extension RegexTransformer {
    
    /// A transformer that applies regex pattern for Russian bank system account number.
    static let rubAccountNumber: Self = .init(regexPattern: #"\d{5}810\d{12}|\d{5}643\d{12}$"#)
}
