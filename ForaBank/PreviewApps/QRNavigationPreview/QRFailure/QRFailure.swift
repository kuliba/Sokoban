//
//  QRFailure.swift
//  QRNavigationPreviewTests
//
//  Created by Igor Malyarov on 06.11.2024.
//

import Combine
import PayHubUI

final class QRFailure {
    
    let details: QRCodeDetails<QRCode>?
    private let selectSubject = PassthroughSubject<Select, Never>()
    
    init(with details: QRCodeDetails<QRCode>?) {
     
        self.details = details
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
