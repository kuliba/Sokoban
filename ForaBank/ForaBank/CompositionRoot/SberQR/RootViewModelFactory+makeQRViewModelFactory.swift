//
//  RootViewModelFactory+makeQRViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    func makeQRViewModelFactory(
        qrResolverFeatureFlag: QRResolverFeatureFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag
    ) -> QRViewModelFactory {
        
        .init(
            makeQRScannerModel: makeMakeQRScannerModel(
                qrResolverFeatureFlag: qrResolverFeatureFlag,
                utilitiesPaymentsFlag: utilitiesPaymentsFlag
            ),
            makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel(),
            makePaymentsSuccessViewModel: makePaymentsSuccessViewModel()
        )
    }
}
