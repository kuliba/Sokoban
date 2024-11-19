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
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        paymentsTransfersFlag: PaymentsTransfersFlag
    ) -> QRViewModelFactory {
        
        return .init(
            makePaymentsSuccessViewModel: makePaymentsSuccessViewModel(),
            makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel(),
            makeQRScannerModel: {
                
                switch paymentsTransfersFlag.rawValue {
                case .active:
                    return nil
                    
                case .inactive:
                    let make = self.makeMakeQRScannerModel(
                        qrResolverFeatureFlag: qrResolverFeatureFlag,
                        utilitiesPaymentsFlag: utilitiesPaymentsFlag
                    )
                    return make()
                }
            }
        )
    }
}
