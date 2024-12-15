//
//  FlowComposer.swift
//
//
//  Created by Igor Malyarov on 29.09.2024.
//

import CombineSchedulers
import Foundation

public final class FlowComposer<Select, Navigation> {
    
    private let delay: Delay
    private let getNavigation: GetNavigation
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    
    /// `delay` is needed to handle SwiftUI writing nil to navigation destination after new destination is already set.
    public init(
        delay: Delay,
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
        let effectHandler = Domain.EffectHandler(
            delay: delay,
            getNavigation: getNavigation,
            scheduler: interactiveScheduler
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
