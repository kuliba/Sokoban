//
//  QRFailure.swift
//  QRNavigationPreviewTests
//
//  Created by Igor Malyarov on 06.11.2024.
//

import Combine

final class QRFailure {
    
    let qrCode: QRCode
    private let selectSubject = PassthroughSubject<Select, Never>()
    
    init(qrCode: QRCode) {
     
        self.qrCode = qrCode
    }
    
    var selectPublisher: AnyPublisher<Select, Never> {
        
        selectSubject.eraseToAnyPublisher()
    }
    
    func select(_ select: Select) {
        
        selectSubject.send(select)
    }
    
    typealias Select = QRFailureDomain.Select
    
    func receive() {
        
    }
}
