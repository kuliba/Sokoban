//
//  FlowComposer.swift
//  
//
//  Created by Igor Malyarov on 29.09.2024.
//

import CombineSchedulers
import Foundation
import PayHub

public final class FlowComposer<Select, Navigation> {
    
    private let microServices: MicroServices
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        microServices: MicroServices,
        scheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.microServices = microServices
        self.scheduler = scheduler
        self.interactiveScheduler = interactiveScheduler
    }
    
    public typealias Domain = FlowDomain<Select, Navigation>
    public typealias MicroServices = Domain.MicroServices
}

public extension FlowComposer {
    
    func compose(
        initialState: Domain.State = .init()
    ) -> Domain.Flow {
        
        let reducer = Domain.Reducer()
        let effectHandler = Domain.EffectHandler(
            microServices: microServices,
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
