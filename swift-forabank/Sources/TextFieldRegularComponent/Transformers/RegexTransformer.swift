//
//  RegexTransformer.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

import Foundation

public struct RegexTransformer: Transformer {
    
    // TODO: Use new Regex API
    private let regexPattern: String
    
    public init(regexPattern: String) {
        self.regexPattern = regexPattern
    }
    
    public func transform(_ input: String) -> String {
        
        guard let regex = try? NSRegularExpression(pattern: regexPattern)
        else { return "" }
        
        let results = regex.matches(in: input, range: .init(location: 0, length: input.count))
        let matches = results.compactMap { (result) -> Substring? in
            
            guard let range = Range(result.range, in: input)
            else { return nil }
            
            return input[range]
        }
        
        return String(matches.joined())
    }
    
    public static let rubAccountNumber: Self = .init(regexPattern: #"\d{5}810\d{12}|\d{5}643\d{12}$"#)
}
