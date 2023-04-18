//
//  LimitingTransformer.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

public struct LimitingTransformer: Transformer {
    
    private let limit: Int
    
    public init(limit: Int) {
        self.limit = limit
    }
    
    public func transform(_ input: String) -> String {
        
        String(input.prefix(limit))
    }
}
