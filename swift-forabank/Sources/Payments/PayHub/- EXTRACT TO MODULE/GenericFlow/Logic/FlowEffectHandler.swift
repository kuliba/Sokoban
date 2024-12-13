//
//  FlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import CombineSchedulers
import Foundation

public final class FlowEffectHandler<Select, Navigation> {
    
    private let delay: Delay
    private let getNavigation: GetNavigation
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    /// - Warning:`Delay` is necessary to handle back-pressure. Keep until `RxViewModel` fix.
    public init(
        delay: Delay = .milliseconds(100),
        getNavigation: @escaping GetNavigation,
        scheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive)
    ) {
        self.delay = delay
        self.getNavigation = getNavigation
        self.scheduler = scheduler
    }
    
    public typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    public typealias NotifyEvent = FlowEvent<Select, Never>
    public typealias Notify = (NotifyEvent) -> Void
    
    public typealias GetNavigation = (Select, @escaping Notify, @escaping (Navigation) -> Void) -> Void
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

private extension FlowEffectHandler {
    
    func handle(
        _ select: Select,
        _ dispatch: @escaping Dispatch
    ) {
        let notify: Notify = { event in
            
            switch event {
            case .dismiss:
                dispatch(.dismiss)
                
            case let .isLoading(isLoading):
                dispatch(.isLoading(isLoading))
                
            case let .select(select):
                dispatch(.select(select))
            }
        }
        
        getNavigation(select, notify) { [weak self] navigation in
            
            guard let self else { return }
            
            scheduler.delay(for: delay) {
                
                dispatch(.receive(navigation))
            }
        }
    }
}

extension AnySchedulerOf<DispatchQueue> {
    
    func delay(
        for timeout: Delay,
        _ action: @escaping () -> Void
    ) {
        schedule(after: .init(.init(uptimeNanoseconds: 0)).advanced(by: timeout), action)
    }
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}
