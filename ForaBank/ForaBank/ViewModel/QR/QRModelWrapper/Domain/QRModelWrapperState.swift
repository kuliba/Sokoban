//
//  QRModelWrapperState.swift
//  ForaBank
//
//  Created by Igor Malyarov on 31.07.2024.
//

enum QRModelWrapperState<QRResult> {
    
    case cancelled
    case inflight
    case qrResult(QRResult)
}

extension QRModelWrapperState: Equatable where QRResult: Equatable {}
