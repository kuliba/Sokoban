//
//  TabModelComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 19.08.2024.
//

import Foundation

final class TabModelComposer {
    
    let makeFlowModel: MakeFlowModel
    
    init(
        makeFlowModel: @escaping MakeFlowModel
    ) {
        self.makeFlowModel = makeFlowModel
    }
    
    typealias MakeFlowModel = (Result<[Latest], Error>) -> PaymentsTransfersModel<PayHubBinder>
}

extension TabModelComposer {
    
    func compose(
        selected: TabState.Selected
    ) -> TabModel {
        
        let reducer = TabReducer()
        let effectHandler = TabEffectHandler()
        
        return .init(
            initialState: .init(
                noLatest: makeFlowModel(.noLatest),
                noCategories: makeFlowModel(.noCategories),
                noBoth: makeFlowModel(.noBoth),
                okEmpty: makeFlowModel(.okEmpty),
                ok: makeFlowModel(.ok),
                selected: selected
            ),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
}

private extension TabModelComposer {
    
    func makeFlowModel(
        _ tab: TabState.Selected
    ) -> TabState.FlowModel {
        
        makeFlowModel(tab.loadResult)
    }
}

private extension TabState.Selected {
    
    var loadResult: PayHubEffectHandler.MicroServices.LoadResult {
        
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

private extension Array where Element == Latest {
    
    static let preview: Self = [
        .init(id: UUID().uuidString),
        .init(id: UUID().uuidString),
        .init(id: UUID().uuidString),
    ]
}
