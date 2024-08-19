//
//  PaymentsTransfersModelComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation

final class PaymentsTransfersModelComposer {}

extension PaymentsTransfersModelComposer {
    
    func compose(
        loadResult: PayHubEffectHandler.MicroServices.LoadResult
    ) -> Model {
        
        return .init(
            payHub: composePayHubBinder(loadResult: loadResult)
        )
    }
    
    typealias Model = PaymentsTransfersModel<PayHubBinder>
}

private extension PaymentsTransfersModelComposer {
    
    func composePayHubBinder(
        loadResult: PayHubEffectHandler.MicroServices.LoadResult
    ) -> PayHubBinder {
        
        let content = PayHubContent.stub(loadResult: loadResult)
        let flow = PayHubFlow.stub()
        
        return .init(content: content, flow: flow)
    }
}

extension PayHubBinder: Loadable {
    
    func load() {
        
        content.event(.load)
    }
}
