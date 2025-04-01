//
//  SplashScreenEffectHandler.swift
//
//
//  Created by Igor Malyarov on 01.04.2025.
//

public final class SplashScreenEffectHandler {
    
    private let load: Load
    
    public init(load: @escaping Load) {
        
        self.load = load
    }
    
    public typealias LoadCompletion = (Settings?) -> Void
    public typealias Load = (@escaping LoadCompletion) -> Void
}

public extension SplashScreenEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .requestUpdate:
            load { dispatch(.update($0)) }
        }
    }
}

public extension SplashScreenEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Settings = SplashScreenState.Settings
    typealias Event = SplashScreenEvent
    typealias Effect = SplashScreenEffect
}
