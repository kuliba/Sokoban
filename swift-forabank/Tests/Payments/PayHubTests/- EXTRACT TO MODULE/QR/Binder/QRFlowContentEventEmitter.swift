//
//  QRFlowContentEventEmitter.swift
//  
//
//  Created by Igor Malyarov on 18.08.2024.
//

import Combine

protocol QRFlowContentEventEmitter {
    
    associatedtype ScanResult
    
    var qrFlowContentEventPublisher: AnyPublisher<QRFlowContentEvent<ScanResult>, Never> { get }
}
