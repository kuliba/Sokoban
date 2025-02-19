//
//  RootViewModelFactory+makeQRViewModelFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.12.2023.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeQRViewModelFactory(
        c2gFlag: C2GFlag,
        paymentsTransfersFlag: PaymentsTransfersFlag
    ) -> QRViewModelFactory {
        
        return .init(
            makePaymentsSuccessViewModel: makePaymentsSuccessViewModel(),
            makeSberQRConfirmPaymentViewModel: makeSberQRConfirmPaymentViewModel,
            makeQRScannerModel: { [weak self] in
                
                switch paymentsTransfersFlag.rawValue {
                case .active:
                    return nil
                    
                case .inactive:
                    return self?.makeQRScannerModel(c2gFlag: c2gFlag)
                }
            }
        )
    }
}
