//
//  PayHubEffectHandler.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public final class PayHubEffectHandler<Latest> {
    
    let microServices: MicroServices
    
    public init(microServices: MicroServices) {
        
        self.microServices = microServices
    }
    
    public typealias MicroServices = PayHubEffectHandlerMicroServices<Latest>
}

public extension PayHubEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case .load:
            microServices.load { [weak self] in
                
                guard self != nil else { return }
                
                dispatch(.loaded(((try? $0.get()) ?? [])))
            }
        }
    }
    
    typealias Item = PayHubItem<Latest>
}

public extension PayHubEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PayHubEvent<Latest>
    typealias Effect = PayHubEffect
}
