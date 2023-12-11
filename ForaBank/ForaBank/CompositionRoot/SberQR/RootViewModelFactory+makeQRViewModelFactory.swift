//
//  RootViewModelFactory+makeQRViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import Foundation

extension RootViewModelFactory {
    
    static func makeQRViewModelFactory(
        model: Model,
        logger: LoggerAgentProtocol,
        qrResolverFeatureFlag: QRResolverFeatureFlag
    ) -> QRViewModelFactory {
        
        .init(
            makeQRScannerModel: makeMakeQRScannerModel(
                model: model,
                qrResolverFeatureFlag: qrResolverFeatureFlag
            ),
            makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel(
                model: model,
                logger: logger
            )
        )
    }
}
