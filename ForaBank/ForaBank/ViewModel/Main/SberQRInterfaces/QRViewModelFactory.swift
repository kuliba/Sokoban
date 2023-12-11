//
//  QRViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import SberQR

struct QRViewModelFactory {
    
    let makeQRScannerModel: MakeQRScannerModel
    let makeSberQRConfirmPaymentViewModel: MakeSberQRConfirmPaymentViewModel
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
            }
        )
    }
}
