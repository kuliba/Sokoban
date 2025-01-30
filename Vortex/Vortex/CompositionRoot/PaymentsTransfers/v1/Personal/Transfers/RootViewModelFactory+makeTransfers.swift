//
//  RootViewModelFactory+makeTransfers.swift
//  Vortex
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
        buttonTypes: [PaymentsTransfersPersonalTransfersDomain.ButtonType] = PaymentsTransfersPersonalTransfersDomain.ButtonType.allCases,
        makeQRModel: @escaping () -> QRScannerModel
    ) -> PaymentsTransfersPersonalTransfersDomain.Binder {
        
        let elements = buttonTypes.map {
            
            PaymentsTransfersPersonalTransfersDomain.Select.buttonType($0)
        }
        let composer = PlainPickerComposer<PaymentsTransfersPersonalTransfersDomain.Select>(scheduler: schedulers.main)
        let content = composer.compose(elements: elements)
        
        return composeBinder(
            content: content,
            delayProvider: delayProvider,
            getNavigation: getNavigation(makeQRModel: makeQRModel),
            witnesses: .init(
                emitting: {
                    
                    $0.$state
                        .compactMap(\.selection)
                        .map { .select($0) }
                },
                dismissing: { content in { content.event(.select(nil)) }}
            )
        )
    }
    
    @inlinable
    func delayProvider(
        navigation: PaymentsTransfersPersonalTransfersDomain.Navigation
    ) -> Delay {
        
        switch navigation {
        case let .failure(failure):
            switch failure {
            case .alert:             return .milliseconds(100)
            case .makeLatestFailure: return .milliseconds(100)
            case .makeMeToMeFailure: return .milliseconds(100)
            }
            
        case let .success(success):
            switch success {
            case .contacts:          return .milliseconds(100)
            case .meToMe:            return .milliseconds(100)
            case .payments:          return .milliseconds(600)
            case .paymentsViewModel: return .milliseconds(600)
            case .scanQR:            return .milliseconds(100)
            case .successMeToMe:     return .milliseconds(100)
            }
        }
    }
    
    @inlinable
    func getNavigation(
        makeQRModel: @escaping () -> QRScannerModel
    ) -> (
        PaymentsTransfersPersonalTransfersDomain.Select,
        @escaping PaymentsTransfersPersonalTransfersDomain.Notify,
        @escaping (PaymentsTransfersPersonalTransfersDomain.Navigation) -> Void
    ) -> Void {
        
        return { [weak self] select, notify, completion in
            
            guard let self else { return }
            
            let nanoServicesComposer = PaymentsTransfersPersonalTransfersNavigationComposerNanoServicesComposer(
                makeQRModel: makeQRModel,
                model: model,
                scheduler: schedulers.main
            )
            
            let navigationComposer = PaymentsTransfersPersonalTransfersNavigationComposer(
                nanoServices: nanoServicesComposer.compose()
            )
            let navigation = navigationComposer.compose(select, notify: notify)
            
            completion(navigation)
        }
    }
}
