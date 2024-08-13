//
//  QRModelWrapperEvent.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.07.2024.
//

enum QRModelWrapperEvent<QRResult> {
    
    case cancel
    case qrResult(QRResult)
    case scanResult(QRViewModel.ScanResult)
}

extension QRModelWrapperEvent: Equatable where QRResult: Equatable {}
