//
//  RootViewModelFactory+makeOperationPicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 21.10.2024.
//

import Foundation
import PayHubUI

extension RootViewModelFactory {
    
    func makeOperationPicker(
        nanoServices: PaymentsTransfersPersonalNanoServices
    ) -> OperationPickerBinder {

        let operationPickerContentComposer = LoadablePickerModelComposer<UUID, OperationPickerElement>(
            load: { completion in
                
                nanoServices.loadAllLatest {
                    
                    completion(((try? $0.get()) ?? []).map { .latest($0) })
                }
            },
            scheduler: mainScheduler
        )
        let operationPickerPlaceholderCount = settings.operationPickerPlaceholderCount
        let operationPickerContent = operationPickerContentComposer.compose(
            prefix: [
                .element(.init(.templates)),
                .element(.init(.exchange))
            ],
            suffix: [],
            placeholderCount: operationPickerPlaceholderCount
        )
        let operationPickerFlowComposer = OperationPickerFlowComposer(
            model: model,
            scheduler: mainScheduler
        )
        let operationPickerFlow = operationPickerFlowComposer.compose()
        
        return .init(
            content: operationPickerContent,
            flow: operationPickerFlow,
            bind: { content, flow in
                
                content.$state
                    .compactMap(\.selected)
                    .sink { flow.event(.select($0)) }
            }
        )
    }
}
