//
//  PaymentsTransfersModelComposer.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Foundation
import PayHub
import PayHubUI

final class PaymentsTransfersModelComposer {}

extension PaymentsTransfersModelComposer {
    
    func compose(
        loadResult: [PayHubPickerItem<Latest>]
    ) -> Model {
        
        return .init(
            categoryPicker: makeCategoryPickerBinder(),
            payHubPicker: makePayHubBinder(loadResult: loadResult)
        )
    }
    
    typealias Model = PaymentsTransfersContentModel
}

// MARK: - CategoryPicker

private extension PaymentsTransfersModelComposer {

    func makeCategoryPickerBinder(
    ) -> CategoryPickerSectionBinder {
        
        return .init(content: (), flow: ())
    }
}

// MARK: - PayHub

private extension PaymentsTransfersModelComposer {
    
    func makePayHubBinder(
        loadResult: [PayHubPickerItem<Latest>]
    ) -> PayHubPickerBinder {
        
        let content = PayHubPickerContent.stub(loadResult: loadResult)
        let flow = PayHubPickerFlow.stub()
        
        return .init(
            content: content, 
            flow: flow,
            bind: { content, flow in
            
                content.$state
                    .map(\.selected)
                    .sink { flow.event(.select($0)) }
            }
        )
    }
}
