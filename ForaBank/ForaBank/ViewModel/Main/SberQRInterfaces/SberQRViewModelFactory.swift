//
//  SberQRViewModelFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 11.12.2023.
//

import SberQR

struct SberQRViewModelFactory {
    
    let makeSberQRConfirmPaymentViewModel: MakeSberQRConfirmPaymentViewModel
}

// MARK: - Preview Content

extension SberQRViewModelFactory {
    
    static func preview() -> Self {
        
        .init(
            makeSberQRConfirmPaymentViewModel: SberQRConfirmPaymentViewModel.preview
        )
    }
}
