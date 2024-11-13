//
//  RootViewModelFactory+makePaymentsTransfersPersonal.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.09.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    func makePaymentsTransfersPersonal(
        nanoServices: PaymentsTransfersPersonalNanoServices,
        makeQRModel: @escaping () -> QRModel
    ) -> PaymentsTransfersPersonal {
        
        // MARK: - CategoryPicker
        
        let categoryPicker = makeCategoryPickerSection(
            nanoServices: nanoServices
        )
        
        // MARK: - OperationPicker
        
        let operationPicker = makeOperationPicker(nanoServices: nanoServices)
        
        // MARK: - Toolbar
        
        let toolbarComposer = PaymentsTransfersPersonalToolbarBinderComposer(
            microServices: .init(
                makeProfile: { $0(ProfileModelStub()) },
                makeQR: { $0(QRModelStub()) }
            ),
            scheduler: schedulers.main
        )
        let toolbar = toolbarComposer.compose()
        
        // MARK: - Transfers
        
        typealias TransfersDomain = PaymentsTransfersPersonalTransfersDomain
        
        let transfers = makeTransfers(
            buttonTypes: TransfersDomain.ButtonType.allCases,
            makeQRModel: makeQRModel
        )
        
        // MARK: - PaymentsTransfers
        
        let content = PaymentsTransfersPersonalContent(
            categoryPicker: categoryPicker,
            operationPicker: operationPicker,
            toolbar: toolbar,
            transfers: transfers,
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
            scheduler: schedulers.main
        )
        
        return .init(content: content, flow: flow, bind: bind)
    }
}

private extension RootViewModelFactory {
    
    func bind(
        content: PaymentsTransfersPersonalContent,
        flow: PaymentsTransfersPersonalFlow
    ) -> Set<AnyCancellable> {
        
        []
    }
}
