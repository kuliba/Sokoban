//
//  Emitting.swift
//  
//
//  Created by Igor Malyarov on 02.09.2024.
//

import Combine

/// - Note: Protocol witness.
public struct Emitting<Model, Value> {
    
    public let model: Model
    public let makePublisher: MakePublisher
    
    public init(
        model: Model, 
        makePublisher: @escaping MakePublisher
    ) {
        self.model = model
        self.makePublisher = makePublisher
    }
    
    public typealias MakePublisher = (Model) -> AnyPublisher<Value, Never>
}
