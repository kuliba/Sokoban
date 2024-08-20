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
    
    private let makeModel: MakeModel
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        makeModel: @escaping MakeModel,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeModel = makeModel
        self.scheduler = scheduler
    }
    
    typealias MakeModel = (Result<[PayHubPickerItem<Latest>], Error>) -> PaymentsTransfersModel<PayHubPickerBinder>
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
                okEmpty: makeBinder(.okEmpty),
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
    
    var loadResult: PayHubPickerEffectHandler.MicroServices.LoadResult {
        
        switch self {
        case .noLatest:
            return .failure(NSError(domain: "Error", code: -1))
            
        case .noCategories:
            return .failure(NSError(domain: "Error", code: -1))
            
        case .noBoth:
            return .failure(NSError(domain: "Error", code: -1))
            
        case .okEmpty:
            return .success([])
            
        case .ok:
            return .success(.preview)
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
