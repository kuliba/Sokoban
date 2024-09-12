//
//  QRFlowEffectHandlerMicroServices.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public struct QRFlowEffectHandlerMicroServices<Destination, ScanResult> {
    
    public let processScanResult: ProcessScanResult
    
    public init(
        processScanResult: @escaping ProcessScanResult
    ) {
        self.processScanResult = processScanResult
    }
}

public extension QRFlowEffectHandlerMicroServices {
    
    typealias ProcessScanResultCompletion = (Destination) -> Void
    typealias ProcessScanResult = (ScanResult, @escaping ProcessScanResultCompletion) -> Void
}
