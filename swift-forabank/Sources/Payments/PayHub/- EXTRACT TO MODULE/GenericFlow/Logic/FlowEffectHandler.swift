//
//  FlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

public final class FlowEffectHandler<Select, Navigation> {
    
    private let microServices: MicroServices
    
    public init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    public typealias MicroServices = FlowEffectHandlerMicroServices<Select, Navigation>
}

public extension FlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .select(select):
            microServices.getNavigation(select, dispatch) {
                
                dispatch(.receive($0))
            }
        }
    }
}

public extension FlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = FlowEvent<Select, Navigation>
    typealias Effect = FlowEffect<Select>
}
