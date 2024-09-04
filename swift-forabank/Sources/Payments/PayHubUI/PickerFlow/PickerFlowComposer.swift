//
//  PickerFlowComposer.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import CombineSchedulers
import Foundation
import PayHub

public final class PickerFlowComposer<Element, Navigation> {
    
    private let makeNavigation: MakeNavigation
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        makeNavigation: @escaping MakeNavigation,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeNavigation = makeNavigation
        self.scheduler = scheduler
    }
    
    public typealias MakeNavigation = (Element, @escaping Dispatch, @escaping (Navigation) -> Void) -> Void
    public typealias Dispatch = (Event) -> Void
    public typealias Event = PickerFlowEvent<Element, Navigation>
}

public extension PickerFlowComposer {
    
    convenience init(
        makeNavigation: @escaping (Element, @escaping (Navigation) -> Void) -> Void,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.init(
            makeNavigation: { element, _, completion in
                
                makeNavigation(element, completion)
            },
            scheduler: scheduler
        )
    }
}

public extension PickerFlowComposer {
    
    func compose(
        initialState: State = .init()
    ) -> Flow {
        
        let reducer = PickerFlowReducer<Element, Navigation>()
        let effectHandler = PickerFlowEffectHandler<Element, Navigation>(makeNavigation: makeNavigation)
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    typealias State = PickerFlowState<Navigation>
    typealias Flow = PickerFlow<Element, Navigation>
}
