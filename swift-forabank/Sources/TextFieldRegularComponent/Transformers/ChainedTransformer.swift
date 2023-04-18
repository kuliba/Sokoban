//
//  ChainedTransformer.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

public struct ChainedTransformer<First, Second>: Transformer
where First: Transformer,
      Second: Transformer {
    
    private let first: First
    private let second: Second
    
    public init(first: First, second: Second) {
        
        self.first = first
        self.second = second
    }
    
    public func transform(_ input: String) -> String {
        
        second.transform(first.transform(input))
    }
}
