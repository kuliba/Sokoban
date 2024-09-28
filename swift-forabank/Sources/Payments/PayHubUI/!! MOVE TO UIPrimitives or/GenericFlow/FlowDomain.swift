//
//  FlowDomain.swift
//
//
//  Created by Igor Malyarov on 28.09.2024.
//

import PayHub
import RxViewModel

/// A namespace.
public enum FlowDomain<Select, Navigation> {}

public extension FlowDomain {
    
    typealias State = FlowState<Navigation>
    typealias Event = FlowEvent<Select, Navigation>
    typealias Effect = FlowEffect<Select>
    
    typealias Flow = RxViewModel<State, Event, Effect>
    
    typealias Reducer = FlowReducer<Select, Navigation>
    typealias EffectHandler = FlowEffectHandler<Select, Navigation>
    typealias MicroServices = FlowEffectHandlerMicroServices<Select, Navigation>
    
#warning("implement")
    // typealias Composer = FlowComposer<Select, Navigation>
}
