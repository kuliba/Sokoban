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
        elements: [PaymentsTransfersPersonalTransfersDomain.Element],
        scheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) -> PaymentsTransfersPersonalTransfersDomain.Binder {
        
        let composer = PaymentsTransfersPersonalTransfersDomain.BinderComposer(
            microServices: .init(
                getNavigation: { _,_,_ in () }
            ),
            scheduler: scheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return composer.compose(elements: elements)
    }
}
