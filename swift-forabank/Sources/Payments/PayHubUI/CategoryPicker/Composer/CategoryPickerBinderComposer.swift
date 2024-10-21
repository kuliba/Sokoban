//
//  CategoryPickerBinderComposer.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub
import RxViewModel

public final class CategoryPickerBinderComposer<Category, QRSelect, Navigation> {
    
    private let load: Load
    private let reload: Load
    private let microServices: MicroServices
    private let placeholderCount: Int
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        load: @escaping Load,
        reload: @escaping Load,
        microServices: MicroServices,
        placeholderCount: Int,
        scheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.load = load
        self.reload = load
        self.microServices = microServices
        self.placeholderCount = placeholderCount
        self.scheduler = scheduler
        self.interactiveScheduler = interactiveScheduler
    }
    
    public typealias Domain = CategoryPickerDomain<Category, QRSelect, Navigation>
    public typealias ContentDomain = Domain.ContentDomain
    public typealias FlowDomain = Domain.FlowDomain
    
    public typealias Load = (@escaping ([Category]?) -> Void) -> Void
    
    public typealias MicroServices = FlowDomain.MicroServices
}

public extension CategoryPickerBinderComposer {
    
    func compose(
        prefix: [CategoryPickerItem],
        suffix: [CategoryPickerItem]
    ) -> Binder {
        
        let content = makeContent(prefix: prefix, suffix: suffix)
        let flow = makeFlow()
        
        return .init(content: content, flow: flow, bind: bind)
    }
    
    typealias CategoryPickerItem = ContentDomain.State.Item
    typealias Binder = Domain.Binder
}

// MARK: - Content

private extension CategoryPickerBinderComposer {
    
    func makeContent(
        prefix: [CategoryPickerItem],
        suffix: [CategoryPickerItem]
    ) -> ContentDomain.Content {
        
        let composer = LoadablePickerModelComposer(
            load: load,
            reload: reload,
            scheduler: scheduler
        )
        
        return composer.compose(
            prefix: prefix,
            suffix: suffix,
            placeholderCount: placeholderCount
        )
    }
}

// MARK: - Flow

private extension CategoryPickerBinderComposer {
    
    func makeFlow() -> FlowDomain.Flow {
        
        let composer = FlowDomain.Composer(
            microServices: microServices,
            scheduler: scheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return composer.compose()
    }
}

// MARK: - bind

private extension CategoryPickerBinderComposer {
    
    func bind(
        _ content: ContentDomain.Content,
        _ flow: FlowDomain.Flow
    ) -> Set<AnyCancellable> {
        
        let flowNavigation = flow.$state.map(\.navigation)
        let dismiss = flowNavigation
            .combineLatest(flowNavigation.dropFirst())
            .filter { $0.0 != nil && $0.1 == nil }
            .debounce(for: .milliseconds(100), scheduler: scheduler)
            .sink { _ in content.event(.select(nil)) }
        
        let select = content.$state
            .compactMap(\.selected)
            .sink { flow.event(.select(.category($0))) }
        
        return [dismiss, select]
    }
}
