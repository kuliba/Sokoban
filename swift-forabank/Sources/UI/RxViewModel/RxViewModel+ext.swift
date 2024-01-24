//
//  RxViewModel+ext.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

public extension RxViewModel {
    
    convenience init(
        initialState: State,
        reducer: any Reducer<State, Event, Effect>,
        effectHandler: any EffectHandler<Event, Effect>,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
