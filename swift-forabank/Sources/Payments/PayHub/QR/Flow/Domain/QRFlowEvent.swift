//
//  QRFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public enum QRFlowEvent<Destination, ScanResult> {

    case dismiss
    case dismissDestination
    case receiveScanResult(ScanResult)
    case setDestination(Destination)
}

extension QRFlowEvent: Equatable where Destination: Equatable, ScanResult: Equatable {}
