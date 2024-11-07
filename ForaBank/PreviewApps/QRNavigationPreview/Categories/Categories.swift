//
//  Categories.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine

final class Categories {
    
    let qrCode: QRCode
    
    private let isClosedSubject = CurrentValueSubject<Bool, Never>(false)
    private let scanQRSubject = PassthroughSubject<Void, Never>()
    
    init(qrCode: QRCode) {
     
        self.qrCode = qrCode
    }
    
    var isClosedPublisher: AnyPublisher<Bool, Never> {
        
        isClosedSubject.eraseToAnyPublisher()
    }
    
    var scanQRPublisher: AnyPublisher<Void, Never> {
        
        scanQRSubject.eraseToAnyPublisher()
    }
    
    func close() {
        
        isClosedSubject.send(true)
    }
    
    func scanQR() {
        
        scanQRSubject.send(())
    }
}
