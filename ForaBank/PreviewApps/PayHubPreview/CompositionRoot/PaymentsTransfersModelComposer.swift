//
//  PaymentsTransfersModelComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation
import PayHub

final class PaymentsTransfersModelComposer {}

extension PaymentsTransfersModelComposer {
    
    func compose(
        loadResult: PayHubPickerEffectHandler.MicroServices.LoadResult
    ) -> Model {
        
        return .init(
            payHub: composePayHubBinder(loadResult: loadResult)
        )
    }
    
    typealias Model = PaymentsTransfersModel<PayHubPickerBinder>
}

private extension PaymentsTransfersModelComposer {
    
    func composePayHubBinder(
        loadResult: PayHubPickerEffectHandler.MicroServices.LoadResult
    ) -> PayHubPickerBinder {
        
        let content = PayHubPickerContent.stub(loadResult: loadResult)
        let flow = PayHubPickerFlow.stub()
        
        return .init(content: content, flow: flow)
    }
}

extension PayHubPickerBinder: Loadable {
    
    func load() {
        
        content.event(.load)
    }
}
