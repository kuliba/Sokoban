//
//  QRScannerViewModelSpy.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 20.11.2024.
//

import Combine
@testable import ForaBank

final class QRScannerViewModelSpy {
    
    private let subject = PassthroughSubject<QRScannerViewAction, Never>()
    
    func complete(with action: QRScannerViewAction) {
        
        subject.send(action)
    }
}

extension QRScannerViewModelSpy: QRScannerViewModel {
    
    var qrScannerViewActionPublisher: AnyPublisher<QRScannerViewAction, Never> {
        
        subject.eraseToAnyPublisher()
    }
}
