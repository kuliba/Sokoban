//
//  QRModel.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine

final class QRModel {
    
    private let subject = PassthroughSubject<QRResult, Never>()
    
    var publisher: AnyPublisher<QRResult, Never> {
        
        subject.eraseToAnyPublisher()
    }
    
    func emit(_ value: QRResult) {
        
        self.subject.send(value)
    }
    
    func receive() {
        
    }
}
