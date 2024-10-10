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
    
    typealias Reducer = FlowReducer<Select, Navigation>
    typealias EffectHandler = FlowEffectHandler<Select, Navigation>
    typealias MicroServices = FlowEffectHandlerMicroServices<Select, Navigation>
    
    typealias Flow = RxViewModel<State, Event, Effect>
    typealias Composer = FlowComposer<Select, Navigation>
}
