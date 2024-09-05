//
//  QRFlowContentEvent.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

public enum QRFlowContentEvent<ScanResult> {
    
    case dismiss
    case scanResult(ScanResult)
}

extension QRFlowContentEvent: Equatable where ScanResult: Equatable {}
