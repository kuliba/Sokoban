//
//  RootViewModelFactory+makeQRFailure.swift
//  ForaBank
//
//  Created by Igor Malyarov on 24.11.2024.
//

extension RootViewModelFactory {
    
    func makeQRFailure(
        qrCode: QRCode?
    ) -> QRFailedViewModelWrapper {
        
        return .init(model: model, qrCode: qrCode, scheduler: schedulers.main)
    }
}
