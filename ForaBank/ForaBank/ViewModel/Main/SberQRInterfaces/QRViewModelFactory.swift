//
//  QRViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import SberQR

struct QRViewModelFactory {
    
    typealias MakePaymentsSuccessViewModel = (CreateSberQRPaymentResponse) -> PaymentsSuccessViewModel
    
    let makeQRScannerModel: MakeQRScannerModel
    let makeSberQRConfirmPaymentViewModel: MakeSberQRConfirmPaymentViewModel
    let makePaymentsSuccessViewModel: MakePaymentsSuccessViewModel
}

// MARK: - Preview Content

extension QRViewModelFactory {
    
    static func preview() -> Self {
        
        .init(
            makeQRScannerModel: QRViewModel.preview,
            makeSberQRConfirmPaymentViewModel: { _,_ in
                
                SberQRConfirmPaymentViewModel(
                    initialState: .editableAmount(.preview),
                    reduce: { state, _ in state },
                    scheduler: .makeMain()
                )
            },
            makePaymentsSuccessViewModel: { _ in .sampleC2BSub }
        )
    }
}
