//
//  FlowComposer.swift
//
//
//  Created by Igor Malyarov on 29.09.2024.
//

import CombineSchedulers
import Foundation

public final class FlowComposer<Select, Navigation> {
    
    private let getNavigation: GetNavigation
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    @available(*, deprecated, message: "Control delays in `getNavigation`.")
    private let delay: Delay?
    
    @available(*, deprecated, message: "Control delays in `getNavigation`.")
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>?
    
    /// `delay` is needed to handle SwiftUI writing nil to navigation destination after new destination is already set.
    public init(
        getNavigation: @escaping GetNavigation,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.getNavigation = getNavigation
        self.scheduler = scheduler
        self.delay = nil
        self.interactiveScheduler = nil
    }
    
    /// `delay` is needed to handle SwiftUI writing nil to navigation destination after new destination is already set.
    @available(*, deprecated, message: "Control delays in `getNavigation`.")
    public init(
        delay: Delay?,
        getNavigation: @escaping GetNavigation,
        scheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.delay = delay
        self.getNavigation = getNavigation
        self.scheduler = scheduler
        self.interactiveScheduler = interactiveScheduler
    }
    
    public typealias Domain = FlowDomain<Select, Navigation>
    public typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    public typealias GetNavigation = Domain.GetNavigation
}

public extension FlowComposer {
    
    func compose(
        initialState: Domain.State = .init()
    ) -> Domain.Flow {
        
        let reducer = Domain.Reducer()
        let effectHandler: Domain.EffectHandler
        
        if let delay, let interactiveScheduler {
            
            effectHandler = .init(
                delay: delay,
                getNavigation: getNavigation,
                scheduler: interactiveScheduler
            )
        } else {
            
            effectHandler = .init(getNavigation: getNavigation)
        }
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
