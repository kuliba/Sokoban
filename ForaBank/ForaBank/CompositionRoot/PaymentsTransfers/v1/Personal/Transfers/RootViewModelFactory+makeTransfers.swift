//
//  RootViewModelFactory+makeTransfers.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2024.
//

import CombineSchedulers
import Foundation
import PayHub
import PayHubUI

extension RootViewModelFactory {
    
    @inlinable
    func makeTransfers(
        buttonTypes: [PaymentsTransfersPersonalTransfersDomain.ButtonType],
        makeQRModel: @escaping () -> QRScannerModel
    ) -> PaymentsTransfersPersonalTransfersDomain.Binder {
        
        let elements = buttonTypes.map {
            
            PaymentsTransfersPersonalTransfersDomain.Select.buttonType($0)
        }
        
        let nanoServicesComposer = PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer(
            makeQRModel: makeQRModel,
            model: model,
            scheduler: schedulers.main
        )
        
        let navigationComposer = PaymentsTransfersPersonalTransfersNavigationComposer(
            nanoServices: nanoServicesComposer.compose()
        )
        
        let composer = PaymentsTransfersPersonalTransfersDomain.BinderComposer(
            microServices: .init(
                getNavigation: { element, notify, completion in
                    
                    let navigation = navigationComposer.compose(element, notify: notify)
                    completion(navigation)
                }
            ),
            scheduler: schedulers.main,
            interactiveScheduler: schedulers.interactive
        )
        
        return composer.compose(elements: elements)
    }
}
