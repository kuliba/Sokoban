//
//  CountdownEffectHandler.swift
//
//
//  Created by Igor Malyarov on 19.01.2024.
//

public final class CountdownEffectHandler {
    
    private let initiate: InitiateOTP
    
    public init(initiate: @escaping InitiateOTP) {
        
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
    
    typealias InitiateOTPResult = Result<Void, ServiceFailure>
    typealias InitiateOTPCompletion = (InitiateOTPResult) -> Void
    typealias InitiateOTP = (@escaping InitiateOTPCompletion) -> Void
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

