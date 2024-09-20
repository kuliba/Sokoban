//
//  BannerPickerSectionBinderComposer.swift
//
//
//  Created by Andryusina Nataly on 08.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub
import RxViewModel
import PayHubUI

public final class BannerPickerSectionBinderComposer<Banner, SelectedBanner, BannerList> {
    
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
    public typealias Item = BannerPickerSectionItem<Banner>
    public typealias BannerPickerItem = LoadablePickerState<UUID, Item>.Item
    public typealias Load = (@escaping ([Item]) -> Void) -> Void
    public typealias MicroServices = BannerPickerSectionFlowEffectHandlerMicroServices<Banner, SelectedBanner, BannerList>
}

public extension BannerPickerSectionBinderComposer {
    
    func compose(
        prefix: [BannerPickerItem],
        suffix: [BannerPickerItem]
    ) -> Binder {
        
        let content = makeContent(prefix: prefix, suffix: suffix)
        let flow = makeFlow()
        
        return .init(content: content, flow: flow, bind: bind)
    }
    
    typealias Binder = BannerPickerSectionBinder<Banner, SelectedBanner, BannerList>
    typealias Content = BannerPickerSectionContent<Banner>
    typealias Flow = BannerPickerSectionFlow<Banner, SelectedBanner, BannerList>
}

// MARK: - Content

private extension BannerPickerSectionBinderComposer {
    
    func makeContent(
        prefix: [BannerPickerItem],
        suffix: [BannerPickerItem]
    ) -> Content {
        
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

private extension BannerPickerSectionBinderComposer {
    
    func makeFlow() -> Flow {
        
        let reducer = BannerPickerSectionFlowReducer<Banner, SelectedBanner, BannerList>()
        let effectHandler = BannerPickerSectionFlowEffectHandler<Banner, SelectedBanner, BannerList>(
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

private extension BannerPickerSectionBinderComposer {
    
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
            .sink { state in
                
                switch state.selected {
                case .none:
                    break
                    
                case let .banner(banner):
                    flow.event(.select(.banner(banner)))
                }
            }
        
        return [dismiss, select]
    }
}
