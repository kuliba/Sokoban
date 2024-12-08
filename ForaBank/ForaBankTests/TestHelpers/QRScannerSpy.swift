//
//  QRScannerSpy.swift
//  VortexTests
//
//  Created by Igor Malyarov on 19.11.2024.
//

import Combine
@testable import Vortex

final class QRScannerSpy {
    
    typealias ScanResult = QRViewModel.ScanResult
    
    private let subject = PassthroughSubject<ScanResult, Never>()
    
    func complete(with result: ScanResult) {
        
        subject.send(result)
    }
}

extension QRScannerSpy: QRScanner {
    
    var scanResultPublisher: AnyPublisher<ScanResult, Never> {
        
        subject.eraseToAnyPublisher()
    }
}
