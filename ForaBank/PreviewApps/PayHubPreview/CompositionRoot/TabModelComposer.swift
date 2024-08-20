//
//  TabModelComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 19.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub

final class TabModelComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
    
    typealias MakeModel = ([PayHubPickerItem<Latest>]) -> PaymentsTransfersModel<PayHubPickerBinder>
}

extension TabModelComposer {
    
    func compose(
        selected: TabState.Selected
    ) -> TabModel {
        
        let reducer = TabReducer()
        let effectHandler = TabEffectHandler()
        
        return .init(
            initialState: .init(
                noLatest: makeBinder(.noLatest),
                noCategories: makeBinder(.noCategories),
                noBoth: makeBinder(.noBoth),
                ok: makeBinder(.ok),
                selected: selected
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

private extension TabModelComposer {
    
    func makeBinder(
        _ tab: TabState.Selected
    ) -> TabState.Binder {
        
        let composer = PaymentsTransfersBinderComposer(
            scheduler: scheduler
        )
        return composer.compose(loadResult: tab.loadResult)
    }
}

// MARK: - stubs

private extension TabState.Selected {
    
    var loadResult: [PayHubPickerItem<Latest>] {
        
        switch self {
        case .noLatest:
            return []
            
        case .noCategories:
            return []
            
        case .noBoth:
            return []
                        
        case .ok:
            return .preview
        }
    }
}

private extension Array where Element == PayHubPickerItem<Latest> {
    
    static let preview: Self = [
        .latest(.preview()),
        .latest(.preview()),
        .latest(.preview())
    ]
}
