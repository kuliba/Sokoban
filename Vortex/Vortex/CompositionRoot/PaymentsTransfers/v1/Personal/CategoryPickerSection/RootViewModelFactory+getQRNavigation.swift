//
//  RootViewModelFactory+getQRNavigation.swift
//  Vortex
//
//  Created by Igor Malyarov on 22.11.2024.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func getQRNavigation(
        qrResult: QRModelResult,
        notify: @escaping QRNavigationComposer.Notify,
        completion: @escaping (QRNavigation) -> Void
    ) {
        let microServicesComposer = QRNavigationComposerMicroServicesComposer(
            httpClient: httpClient,
            logger: logger,
            model: model,
            createSberQRPayment: createSberQRPayment,
            getSberQRData: getSberQRData,
            makeSegmented: makeSegmentedPaymentProviderPickerFlowModel,
            makeServicePicker: makeAnywayServicePickerFlowModel,
            scanner: scanner,
            scheduler: schedulers.main
        )
        let microServices = microServicesComposer.compose()
        let composer = QRNavigationComposer(microServices: microServices)
        
        composer.getNavigation(
            payload: .qrResult(qrResult),
            notify: notify
        ) {
            completion($0)
            _ = composer
        }
    }
}
