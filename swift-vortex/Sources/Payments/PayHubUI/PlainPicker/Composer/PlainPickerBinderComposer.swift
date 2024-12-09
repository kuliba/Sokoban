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

public typealias PlainPickerBinderComposer<Element, Navigation> = BinderComposer<PlainPickerContent<Element>, Element, Navigation>

public extension PlainPickerBinderComposer {
    
    convenience init(
        elements: [Select],
        delay: Delay = .milliseconds(100),
        getNavigation: @escaping GetNavigation,
        schedulers: Schedulers = .init()
    ) where Content == PlainPickerContent<Select> {
        
        let reducer = PickerContentReducer<Select>()
        let effectHandler = PickerContentEffectHandler<Select>()
        
        let content = PlainPickerContent<Select>(
            initialState: .init(elements: elements),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: schedulers.main
        )
        
        self.init(
            delay: delay,
            getNavigation: getNavigation,
            makeContent: { content },
            schedulers: schedulers,
            witnesses: .init(
                emitting: { $0.$state.compactMap(\.selection) },
                dismissing: { content in { content.event(.select(nil)) }}
            )
        )
    }
}

public final class _PlainPickerBinderComposer<Element, Navigation> {
    
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
    
    public typealias Domain = FlowDomain<Element, Navigation>
    public typealias MicroServices = Domain.MicroServices
}

public extension _PlainPickerBinderComposer {
    
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

private extension _PlainPickerBinderComposer {
    
    typealias Content = PlainPickerContent<Element>
    typealias Flow = Domain.Flow
    
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
        
        let composer = Domain.Composer(
            microServices: microServices,
            scheduler: scheduler,
            interactiveScheduler: interactiveScheduler
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
