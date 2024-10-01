//
//  CategoryPickerSectionBinderComposer.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub
import RxViewModel

public final class CategoryPickerSectionBinderComposer<Category, Navigation> {
    
    private let load: Load
    private let microServices: MicroServices
    private let placeholderCount: Int
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        load: @escaping Load,
        microServices: MicroServices,
        placeholderCount: Int,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.load = load
        self.microServices = microServices
        self.placeholderCount = placeholderCount
        self.scheduler = scheduler
    }
    
    public typealias Domain = CategoryPickerSection<Category, Navigation>
    public typealias FlowDomain = Domain.FlowDomain
    public typealias ContentDomain = Domain.ContentDomain
    
    public typealias Item = ContentDomain.Item
    public typealias Load = (@escaping ([Item]) -> Void) -> Void
    
    public typealias MicroServices = FlowDomain.MicroServices
}

public extension CategoryPickerSectionBinderComposer {
    
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

private extension CategoryPickerSectionBinderComposer {
    
    func makeContent(
        prefix: [CategoryPickerItem],
        suffix: [CategoryPickerItem]
    ) -> ContentDomain.Content {
        
        let composer = LoadablePickerModelComposer(
            load: load,
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

private extension CategoryPickerSectionBinderComposer {
    
    func makeFlow() -> FlowDomain.Flow {
        
        let composer = FlowDomain.Composer(
            microServices: microServices, 
            scheduler: scheduler
        )
        
        return composer.compose()
    }
}

// MARK: - bind

private extension CategoryPickerSectionBinderComposer {
    
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
            .sink {
                
                switch $0.selected {
                case .none:
                    break
                    
                case let .category(category):
                    flow.event(.select(.category(category)))
                    
                case .list:
                    let categories: [Category] = $0.items.compactMap {
                        
                        guard case let .element(element) = $0,
                              case let .category(category) = element.element
                        else { return nil }
                        
                        return category
                    }
                    flow.event(.select(.list(categories)))
                }
            }
        
        return [dismiss, select]
    }
}
