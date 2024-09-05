//
//  PlainPickerBinderComposer.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub

public final class PlainPickerBinderComposer<Element, Navigation> {
    
    private let makeNavigation: MakeNavigation
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        makeNavigation: @escaping MakeNavigation,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeNavigation = makeNavigation
        self.scheduler = scheduler
    }
    
    public typealias MakeNavigation = (Element, @escaping (Navigation) -> Void) -> Void
}

public extension PlainPickerBinderComposer {
    
    func compose(
        elements: [Element]
    ) -> Binder {
        
        return .init(
            content: makeContent(elements: elements),
            flow: makeFlow(),
            bind: bind
        )
    }
    
    typealias Binder = PlainPickerBinder<Element, Navigation>
}

private extension PlainPickerBinderComposer {
    
    typealias Content = PlainPickerContent<Element>
    typealias Flow = PlainPickerFlow<Element, Navigation>
    
    func makeContent(
        elements: [Element]
    ) -> Content {
        
        let reducer = PickerContentReducer<Element>()
        let effectHandler = PickerContentEffectHandler<Element>()
        
        return .init(
            initialState: .init(elements: elements),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
    
    func makeFlow() -> Flow {
        
        let composer = PickerFlowComposer(
            makeNavigation: makeNavigation,
            scheduler: scheduler
        )
        return composer.compose()
    }
    
    func bind(
        _ content: Content,
        _ flow: Flow
    ) -> Set<AnyCancellable> {
        
        let contentToFlow = content.$state
            .compactMap(\.selection)
            .sink { [weak flow] in flow?.event(.select($0)) }
        
        let flowNavigation = flow.$state.map(\.navigation)
        let flowToContent = flowNavigation
            .combineLatest(flowNavigation.dropFirst())
            .filter { $0.0 != nil && $0.1 == nil }
            .debounce(for: .milliseconds(100), scheduler: scheduler)
            .sink { [weak content] _ in content?.event(.select(nil)) }
        
        return [contentToFlow, flowToContent]
    }
}
