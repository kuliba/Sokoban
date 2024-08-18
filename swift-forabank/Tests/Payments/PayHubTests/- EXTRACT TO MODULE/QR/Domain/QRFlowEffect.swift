//
//  QRFlowEffect.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

enum QRFlowEffect<ScanResult> {
    
    case processScanResult(ScanResult)
}

extension QRFlowEffect: Equatable where ScanResult: Equatable {}
