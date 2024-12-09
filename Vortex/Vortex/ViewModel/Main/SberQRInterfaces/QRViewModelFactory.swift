//
//  QRViewModelFactory.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.12.2023.
//

import SberQR

struct QRViewModelFactory {
    
    let makePaymentsSuccessViewModel: MakePaymentsSuccessViewModel
    let makeSberQRConfirmPaymentViewModel: MakeSberQRConfirmPaymentViewModel
    let makeQRScannerModel: MakeQRScannerModel
    
    typealias MakePaymentsSuccessViewModel = (CreateSberQRPaymentResponse) -> PaymentsSuccessViewModel
    typealias MakeQRScannerModel = () -> QRScannerModel?
}

// MARK: - Preview Content

extension QRViewModelFactory {
    
    static func preview() -> Self {
        
        return .init(
            makePaymentsSuccessViewModel: { _ in .sampleC2BSub },
            makeSberQRConfirmPaymentViewModel: { _,_ in
                
                return .init(
                    initialState: .init(confirm: .editableAmount(.preview)),
                    reduce: { state, _ in state },
                    scheduler: .makeMain()
                )
            },
            makeQRScannerModel: QRModelWrapper.preview
        )
    }
}

extension QRModelWrapper
where QRResult == QRViewModel.ScanResult {
    
    static func preview() -> QRModelWrapper {
        
        return .init(
            mapScanResult: { _, completion in completion(.unknown) },
            makeQRScanner: QRViewModel.preview,
            scheduler: .main
        )
    }
}

extension QRModelWrapper
where QRResult == QRModelResult {
    
    static func preview() -> QRModelWrapper {
        
        return .init(
            mapScanResult: { _, completion in completion(.unknown) },
            makeQRScanner: QRViewModel.preview,
            scheduler: .main
        )
    }
}
