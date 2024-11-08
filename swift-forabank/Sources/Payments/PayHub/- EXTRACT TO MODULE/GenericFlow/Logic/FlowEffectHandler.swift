//
//  FlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import CombineSchedulers
import Foundation

public final class FlowEffectHandler<Select, Navigation> {
    
    private let microServices: MicroServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        microServices: MicroServices,
        scheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive)
    ) {
        self.microServices = microServices
        self.scheduler = scheduler
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
            handle(select, dispatch)
        }
    }
}

public extension FlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = FlowEvent<Select, Navigation>
    typealias Effect = FlowEffect<Select>
}

public extension FlowEffectHandler {
    
    func handle(
        _ select: Select,
        _ dispatch: @escaping Dispatch
    ) {
        let notify = { (event: MicroServices.NotifyEvent) in
            
            switch event {
            case .dismiss:
                dispatch(.dismiss)
                
            case let .select(select):
                dispatch(.select(select))
            }
        }
        
        microServices.getNavigation(select, notify) { [weak self] navigation in
            
            self?.scheduler.delay(for: .milliseconds(100)) {
                
                dispatch(.receive(navigation))
            }
        }
    }
}

extension AnySchedulerOf<DispatchQueue> {
    
    func delay(
        for timeout: DispatchTimeInterval,
        _ action: @escaping () -> Void
    ) {
        schedule(after: .init(.now() + timeout), action)
    }
}
