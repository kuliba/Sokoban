//
//  CountdownEffectHandler.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public final class CountdownEffectHandler {
    
    private let initiate: Initiate
    
    public init(initiate: @escaping Initiate) {
        
        self.initiate = initiate
    }
}

public extension CountdownEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .initiate:
            initiate(dispatch)
        }
    }
}

public extension CountdownEffectHandler {
    
    typealias InitiateResult = Result<Void, CountdownFailure>
    typealias InitiateCompletion = (InitiateResult) -> Void
    typealias Initiate = (@escaping InitiateCompletion) -> Void
}

public extension CountdownEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias State = CountdownState
    typealias Event = CountdownEvent
    typealias Effect = CountdownEffect
}

private extension CountdownEffectHandler {
    
    func initiate(
        _ dispatch: @escaping Dispatch
    ) {
        initiate { result in
        
            switch result {
            case let .failure(countdownFailure):
                dispatch(.failure(countdownFailure))
                
            case .success(()):
                dispatch(.start)
            }
        }
    }
}

