//
//  RootViewModelFactory+makeQRViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeQRViewModelFactory(
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
                    return self?.makeQRScannerModel()
                }
            }
        )
    }
}
