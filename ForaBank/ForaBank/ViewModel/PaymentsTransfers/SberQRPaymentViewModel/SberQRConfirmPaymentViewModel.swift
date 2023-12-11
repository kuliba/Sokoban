//
//  SberQRConfirmPaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation
import SberQR

extension SberQRConfirmPaymentViewModel {
    
    typealias Commit = CreateSberQRPaymentCompletion
    
    static func preview(
        sberQRURL: URL,
        sberQRData: GetSberQRDataResponse,
        commit: @escaping Commit,
        pay: @escaping (SberQRConfirmPaymentState) -> Void = { _ in }
    ) -> SberQRConfirmPaymentViewModel {
                
        return .default(
            initialState: .editableAmount(.preview),
            getProducts: { [] },
            pay: pay,
            scheduler: .main
        )
    }
}
