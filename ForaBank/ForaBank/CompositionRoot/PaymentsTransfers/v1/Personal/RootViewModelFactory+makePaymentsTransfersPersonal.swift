//
//  RootViewModelFactory+makePaymentsTransfersPersonal.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    func makePaymentsTransfersPersonal(
        categoryPickerPlaceholderCount: Int,
        operationPickerPlaceholderCount: Int,
        nanoServices: PaymentsTransfersPersonalNanoServices,
        pageSize: Int
    ) -> PaymentsTransfersPersonal {
        
        // MARK: - CategoryPicker
        
        let categoryPicker = makeCategoryPickerSection(
            nanoServices: nanoServices,
            pageSize: pageSize,
            placeholderCount: categoryPickerPlaceholderCount
        )
        
        // MARK: - OperationPicker
        
        let operationPickerContentComposer = LoadablePickerModelComposer<UUID, OperationPickerElement>(
            load: { completion in
                
                nanoServices.loadAllLatest {
                    
                    completion(((try? $0.get()) ?? []).map { .latest($0) })
                }
            },
            scheduler: mainScheduler
        )
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
        let operationPicker = OperationPickerBinder(
            content: operationPickerContent,
            flow: operationPickerFlow,
            bind: { content, flow in
                
                content.$state
                    .compactMap(\.selected)
                    .sink { flow.event(.select($0)) }
            }
        )
        
        // MARK: - Toolbar
        
        let toolbarComposer = PaymentsTransfersPersonalToolbarBinderComposer(
            microServices: .init(
                makeProfile: { $0(ProfileModelStub()) },
                makeQR: { $0(QRModelStub()) }
            ),
            scheduler: mainScheduler
        )
        let toolbar = toolbarComposer.compose()
        
        // MARK: - PaymentsTransfers
        
        let content = PaymentsTransfersPersonalContent(
            categoryPicker: categoryPicker,
            operationPicker: operationPicker,
            toolbar: toolbar,
            reload: {
                
                categoryPicker.content.event(.reload)
                operationPicker.content.event(.reload)
            }
        )
        
        let reducer = PayHub.PaymentsTransfersPersonalFlowReducer()
        let effectHandler = PayHub.PaymentsTransfersPersonalFlowEffectHandler(
            microServices: .init()
        )
        let flow = PaymentsTransfersPersonalFlow(
            initialState: .init(),
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: mainScheduler
        )
        
        return .init(content: content, flow: flow, bind: { _,_ in [] })
    }
}
