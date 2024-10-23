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
    
    func makeTransfers(
        elements: [PaymentsTransfersPersonalTransfersDomain.Element]
    ) -> PaymentsTransfersPersonalTransfersDomain.Binder {
        
        let nanoServicesComposer = PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer(
            model: model, 
            scheduler: mainScheduler
        )
        
        let navigationComposer = PaymentsTransfersPersonalTransfersNavigationComposer(
            nanoServices: nanoServicesComposer.compose()
        )
        
        let composer = PaymentsTransfersPersonalTransfersDomain.BinderComposer(
            microServices: .init(
                getNavigation: { element, notify, completion in
                    
                    guard let navigation = navigationComposer.compose(element)
                    else {
                        #warning("return without navigation")
                        return
                    }
                    
                    completion(navigation)
                }
            ),
            scheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return composer.compose(elements: elements)
    }
}
