//
//  QRFlowEvent.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

enum QRFlowEvent<Destination, ScanResult> {

    case destination(Destination)
    case dismiss
    case dismissDestination
    case receiveScanResult(ScanResult)
}

extension QRFlowEvent: Equatable where Destination: Equatable, ScanResult: Equatable {}
