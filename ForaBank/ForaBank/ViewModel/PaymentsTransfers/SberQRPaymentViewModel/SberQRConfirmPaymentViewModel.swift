//
//  SberQRConfirmPaymentViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.12.2023.
//

import Foundation
import SberQR

extension SberQRConfirmPaymentViewModel {
    
    typealias Commit = MakeSberQRPaymentCompletion
    
    static func preview(
        sberQRURL: URL,
        sberQRData: GetSberQRDataResponse,
        commit: @escaping Commit
    ) -> SberQRConfirmPaymentViewModel {
                
        return .default(
            initialState: .editableAmount(.preview),
            getProducts: { [] },
            pay: { _ in },
            scheduler: .main
        )
    }
}
