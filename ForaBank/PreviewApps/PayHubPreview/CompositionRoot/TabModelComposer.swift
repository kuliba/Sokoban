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
    
    private let hasCorporateCardsOnly: HasCorporateCardsOnly
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        hasCorporateCardsOnly: HasCorporateCardsOnly,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.hasCorporateCardsOnly = hasCorporateCardsOnly
        self.scheduler = scheduler
    }
    
    typealias HasCorporateCardsOnly = AnyPublisher<Bool, Never>
    typealias MakeModel = ([OperationPickerElement]) -> PaymentsTransfersPersonalContent
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
            hasCorporateCardsOnly: hasCorporateCardsOnly,
            corporate: .init(),
            personal: makeBinder(tab)
        )
    }
    
    func makeBinder(
        _ tab: PaymentsTransfersTabState.Selected
    ) -> PaymentsTransfersPersonal {
        
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
    
    var loadResult: [OperationPickerElement] {
        
        switch self {
        case .noLatest:     return []
        case .noCategories: return .preview
        case .noBoth:       return []
        case .ok:           return .preview
        }
    }
}

private extension Array where Element == OperationPickerElement {
    
    static let preview: Self = [
        .latest(.preview()),
        .latest(.preview()),
        .latest(.preview())
    ]
}

extension Array where Element == ServiceCategory {
    
    static let preview: Self = [
        .make("Failure"),
        .make("Mobile"),
        .make("QR"),
        .make("Tax"),
        .make("Transport"),
        .make("Utility"),
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
