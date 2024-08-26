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

public final class CategoryPickerSectionBinderComposer<Category, CategoryModel, CategoryList> {
    
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
    
    public typealias Item = CategoryPickerSectionItem<Category>
    public typealias Load = (@escaping ([Item]) -> Void) -> Void
    public typealias MicroServices = CategoryPickerSectionFlowEffectHandlerMicroServices<Category, CategoryModel, CategoryList>
}

public extension CategoryPickerSectionBinderComposer {
    
    func compose() -> Binder {
        
        let content = makeContent()
        let flow = makeFlow()
        
        return .init(content: content, flow: flow, bind: bind)
    }
    
    typealias Binder = CategoryPickerSectionBinder<Category, CategoryModel, CategoryList>
    typealias Content = CategoryPickerSectionContent<Category>
    typealias Flow = CategoryPickerSectionFlow<Category, CategoryModel, CategoryList>
}

// MARK: - Content

private extension CategoryPickerSectionBinderComposer {
    
    func makeContent() -> Content {
        
        let composer = LoadablePickerModelComposer(
            load: load,
            scheduler: scheduler
        )
        
        return composer.compose(
            prefix: [],
            suffix: [],
            placeholderCount: placeholderCount
        )
    }
}

// MARK: - Flow

private extension CategoryPickerSectionBinderComposer {
    
    func makeFlow() -> Flow {
        
        let reducer = CategoryPickerSectionFlowReducer<Category, CategoryModel, CategoryList>()
        let effectHandler = CategoryPickerSectionFlowEffectHandler<Category, CategoryModel, CategoryList>(
            microServices: microServices
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}

// MARK: - bind

private extension CategoryPickerSectionBinderComposer {
    
    func bind(
        _ content: Content,
        _ flow: Flow
    ) -> Set<AnyCancellable> {
        
        let flowDestination = flow.$state.map(\.destination)
        let dismiss = flowDestination
            .combineLatest(flowDestination.dropFirst())
            .filter { $0.0 != nil && $0.1 == nil }
            .debounce(for: .milliseconds(100), scheduler: scheduler)
            .sink { _ in content.event(.select(nil)) }
        
        let select = content.$state
            .compactMap(\.selected)
            .sink {
                
                switch $0 {
                case let .category(category):
                    flow.event(.select(.category(category)))
                    
                case .showAll:
                    flow.event(.select(.list))
                }
            }
        
        return [dismiss, select]
    }
}
