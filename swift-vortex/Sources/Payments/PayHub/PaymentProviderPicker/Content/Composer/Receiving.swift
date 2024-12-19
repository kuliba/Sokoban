//
//  Receiving.swift
//  
//
//  Created by Igor Malyarov on 02.09.2024.
//

/// - Note: Protocol witness.
public struct Receiving<Model, Value> {
    
    public let model: Model
    public let makeReceive: MakeReceive
    
    public init(
        model: Model, 
        makeReceive: @escaping MakeReceive
    ) {
        self.model = model
        self.makeReceive = makeReceive
    }
    
    public typealias MakeReceive = (Model) -> (Value) -> Void
}
