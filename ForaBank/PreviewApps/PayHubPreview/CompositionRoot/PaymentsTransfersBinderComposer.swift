//
//  PaymentsTransfersBinderComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 19.08.2024.
//

import CombineSchedulers
import Foundation

final class PaymentsTransfersBinderComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.scheduler = scheduler
    }
}

extension PaymentsTransfersBinderComposer {
    
    typealias Binder = PaymentsTransfersBinder<PayHubBinder>
 
    func compose(
        loadResult: Result<[Latest], Error>
    ) -> Binder {
        
        let contentComposer = PaymentsTransfersModelComposer()
        let flowComposer = PaymentsTransfersFlowModelComposer(
            scheduler: scheduler
        )
        
        return .init(
            content: contentComposer.compose(loadResult: loadResult),
            flow: flowComposer.compose()
        )
    }
}
