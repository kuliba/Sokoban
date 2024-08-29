//
//  TabModelComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 19.08.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub

final class TabModelComposer {
    
    private let isCorporateOnly: IsCorporateOnly
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        isCorporateOnly: IsCorporateOnly,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.isCorporateOnly = isCorporateOnly
        self.scheduler = scheduler
    }
    
    typealias IsCorporateOnly = AnyPublisher<Bool, Never>
    typealias MakeModel = ([OperationPickerItem<Latest>]) -> PaymentsTransfersContent
}

extension TabModelComposer {
    
    func compose(
        selected: PaymentsTransfersTabState.Selected
    ) -> TabModel<PaymentsTransfersSwitcher> {
        
        let reducer = TabReducer<PaymentsTransfersSwitcher>()
        let effectHandler = TabEffectHandler<PaymentsTransfersSwitcher>()
        
        return .init(
            initialState: .init(
                noLatest: makeSwitcher(.noLatest),
                noCategories: makeSwitcher(.noCategories),
                noBoth: makeSwitcher(.noBoth),
                ok: makeSwitcher(.ok),
                selected: selected
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

private extension TabModelComposer {
    
    func makeSwitcher(
        _ tab: PaymentsTransfersTabState.Selected
    ) -> PaymentsTransfersSwitcher {
        
        return .init(
            isCorporateOnly: isCorporateOnly,
            corporate: .init(),
            personal: makeBinder(tab)
        )
    }
    
    func makeBinder(
        _ tab: PaymentsTransfersTabState.Selected
    ) -> PaymentsTransfersBinder {
        
        let composer = PaymentsTransfersBinderComposer(
            scheduler: scheduler
        )
        return composer.compose(
            loadedCategories: tab.loadedCategories,
            loadedItems: tab.loadResult
        )
    }
}

// MARK: - stubs

private extension TabState.Selected {
    
    var loadedCategories: [ServiceCategory] {
        
        switch self {
        case .noLatest:     return .preview
        case .noCategories: return []
        case .noBoth:       return []
        case .ok:           return .preview
        }
    }
    
    var loadResult: [OperationPickerItem<Latest>] {
        
        switch self {
        case .noLatest:     return []
        case .noCategories: return .preview
        case .noBoth:       return []
        case .ok:           return .preview
        }
    }
}

private extension Array where Element == OperationPickerItem<Latest> {
    
    static let preview: Self = [
        .latest(.preview()),
        .latest(.preview()),
        .latest(.preview())
    ]
}

extension Array where Element == ServiceCategory {
    
    static let preview: Self = [
        .make("Category A"),
        .make("Category B"),
        .make("Category C"),
        .make("Category D"),
    ]
}

private extension ServiceCategory {
    
    static func make(_ name: String) -> Self {
        
        return .init(name: name)
    }
}

private extension Latest {
    
    static func preview() -> Self {
        
        return .init(id: UUID().uuidString)
    }
}
