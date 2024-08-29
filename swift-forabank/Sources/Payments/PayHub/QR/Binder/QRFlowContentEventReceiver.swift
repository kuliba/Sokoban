//
//  QRFlowContentEventReceiver.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

public protocol QRFlowContentEventReceiver {
    
    associatedtype ScanResult
    
    func receive(_: QRFlowContentEvent<ScanResult>)
}
