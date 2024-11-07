//
//  Payments.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import Foundation

final class Payments {
    
    private let isClosedSubject = CurrentValueSubject<Bool, Never>(false)
    private let scanQRSubject = PassthroughSubject<Void, Never>()
    
    let source: Source
    
    init(source: Source) {
        
        self.source = source
    }
    
    init(url: URL) {
        
        self.source = .url(url)
    }
    
    init(qrCode: QRCode) {
        
        self.source = .qrCode(qrCode)
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
    
    enum Source {
        
        case qrCode(QRCode)
        case url(URL)
    }
}
