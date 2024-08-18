//
//  QRFlowEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

struct QRFlowEffectHandlerMicroServices<Destination, ScanResult> {
    
    let processScanResult: ProcessScanResult
}

extension QRFlowEffectHandlerMicroServices {
    
    typealias ProcessScanResultCompletion = (Destination) -> Void
    typealias ProcessScanResult = (ScanResult, @escaping ProcessScanResultCompletion) -> Void
}
