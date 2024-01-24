//
//  URL+matches.swift
//  
//
//  Created by Igor Malyarov on 07.12.2023.
//

import Foundation

public extension URL {
    
    func matches(contents: [String]) -> Bool {
        
        for content in contents {
            
            if absoluteString.contains(content) {
                
                return true
            }
        }
        
        return false
    }
    
    func matches(
        _ paymentType: String,
        in pairs: [(content: String, paymentType: String)]
    ) -> Bool {
        
        let contents = pairs
            .filter { $0.paymentType == paymentType }
            .map(\.content)
        
        return matches(contents: contents)
    }
}
