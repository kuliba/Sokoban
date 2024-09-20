//
//  OperationPickerFlow+stub.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import CombineSchedulers
import Foundation

extension OperationPickerFlow {
    
    static func stub(
        initialState: OperationPickerFlowState = .init(),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) -> OperationPickerFlow {
        
        let composer = OperationPickerFlowMakeNavigationComposer()
        
        let reducer = OperationPickerFlowReducer()
        let effectHandler = OperationPickerFlowEffectHandler(
            makeNavigation: composer.compose()
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
