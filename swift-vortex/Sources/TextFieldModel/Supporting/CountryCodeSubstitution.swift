//
//  CountryCodeSubstitution.swift
//  
//
//  Created by Igor Malyarov on 17.05.2023.
//

public struct CountryCodeSubstitution {
    
    public let from: String
    public let to: String
    
    public init(from: String, to: String) {
        self.from = from
        self.to = to
    }
}

extension Array where Element == CountryCodeSubstitution {
    
    public func firstTo(matching match: String) -> String? {
        
        first(where: { $0.from == match })?.to
    }
}
