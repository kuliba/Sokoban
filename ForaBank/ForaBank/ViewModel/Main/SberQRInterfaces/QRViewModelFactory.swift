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
            makeQRScannerModel: QRModelWrapper.preview,
            makeSberQRConfirmPaymentViewModel: { _,_ in
                
                return .init(
                    initialState: .init(confirm: .editableAmount(.preview)),
                    reduce: { state, _ in state },
                    scheduler: .makeMain()
                )
            },
            makePaymentsSuccessViewModel: { _ in .sampleC2BSub }
        )
    }
}

extension QRModelWrapper where QRResult == QRViewModel.ScanResult {
    
    static func preview() -> QRModelWrapper {
        
        return .init(
            mapScanResult: { _, completion in completion(.unknown) },
            makeQRModel: QRViewModel.preview,
            scheduler: .main
        )
    }
}

extension QRModelWrapper where QRResult == QRModelResult {
    
    static func preview() -> QRModelWrapper {
        
        return .init(
            mapScanResult: { _, completion in completion(.unknown) },
            makeQRModel: QRViewModel.preview,
            scheduler: .main
        )
    }
}
