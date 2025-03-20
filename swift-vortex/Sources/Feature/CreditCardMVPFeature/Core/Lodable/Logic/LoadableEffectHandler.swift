//
//  LoadableEffectHandler.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

public final class LoadableEffectHandler<Resource, Failure: Error> {
    
    private let load: Load
    
    public init(load: @escaping Load) {
        
        self.load = load
    }
    
    public typealias Load = (@escaping (Result<Resource, Failure>) -> Void) -> Void
}

public extension LoadableEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            load { dispatch(.loaded($0)) }
        }
    }
}

public extension LoadableEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = LoadableEvent<Resource, Failure>
    typealias Effect = LoadableEffect
}
