//
//  RootViewModelFactory+makeQRViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    static func makeQRViewModelFactory(
        model: Model,
        logger: LoggerAgentProtocol,
        qrResolverFeatureFlag: QRResolverFeatureFlag,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> QRViewModelFactory {
        
        .init(
            makeQRScannerModel: makeMakeQRScannerModel(
                model: model,
                qrResolverFeatureFlag: qrResolverFeatureFlag,
                scheduler: scheduler
            ),
            makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel(
                model: model,
                logger: logger
            ),
            makePaymentsSuccessViewModel: makePaymentsSuccessViewModel(
                model: model
            )
        )
    }
}
