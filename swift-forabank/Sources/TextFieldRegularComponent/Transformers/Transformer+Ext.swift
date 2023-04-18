//
//  Transformer+Ext.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

// MARK: - Ergonomics

public extension Transformer {
    
    func chained<T: Transformer>(
        with transformer: T
    ) -> ChainedTransformer<Self, T> {
        
        .init(first: self, second: transformer)
    }
    
    func regex(
        pattern: String
    ) -> ChainedTransformer<Self, RegexTransformer> {
    
        .init(first: self, second: .init(regexPattern: pattern))
    }
    
    func limit(
        _ limit: Int
    ) -> ChainedTransformer<Self, LimitingTransformer> {
    
        .init(first: self, second: .init(limit: limit))
    }
    
    func numbers() -> ChainedTransformer<Self, FilteringTransformer> {
    
        .init(first: self, second: .numbers)
    }
    
    func letters() -> ChainedTransformer<Self, FilteringTransformer> {
    
        .init(first: self, second: .letters)
    }
}
