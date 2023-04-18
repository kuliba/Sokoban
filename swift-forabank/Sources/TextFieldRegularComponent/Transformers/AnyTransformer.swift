//
//  AnyTransformer.swift
//  
//
//  Created by Igor Malyarov on 16.04.2023.
//

public struct AnyTransformer: Transformer {
    
    private let _transform: (String) -> String
    
    public init(_transform: @escaping (String) -> String) {
        
        self._transform = _transform
    }
    
    public func transform(_ input: String) -> String {
        
        _transform(input)
    }
}
