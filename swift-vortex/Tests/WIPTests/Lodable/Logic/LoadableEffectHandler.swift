//
//  LoadableEffectHandler.swift
//
//
//  Created by Igor Malyarov on 20.03.2025.
//

final class LoadableEffectHandler<Resource, Failure: Error> {
    
    private let load: Load
    
    init(load: @escaping Load) {
        
        self.load = load
    }
    
    typealias Load = (@escaping (Result<Resource, Failure>) -> Void) -> Void
}

extension LoadableEffectHandler {
    
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

extension LoadableEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = LoadableEvent<Resource, Failure>
    typealias Effect = LoadableEffect
}
