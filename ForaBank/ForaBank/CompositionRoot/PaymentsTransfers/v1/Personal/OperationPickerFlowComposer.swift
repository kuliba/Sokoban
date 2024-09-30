//
//  OperationPickerFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

final class OperationPickerFlowComposer {
    
    private let model: Model
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        model: Model,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.model = model
        self.scheduler = scheduler
    }
}

extension OperationPickerFlowComposer {
    
    func compose() -> OperationPickerFlow {
        
        let composer = OperationPickerFlowMakeNavigationComposer(model: model)
        
        let reducer = OperationPickerFlowReducer()
        let effectHandler = OperationPickerFlowEffectHandler(
            makeNavigation: composer.compose()
        )
        
        return .init(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: scheduler
        )
    }
}
