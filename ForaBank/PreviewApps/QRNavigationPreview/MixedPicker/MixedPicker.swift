//
//  MixedPicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine

final class MixedPicker {
    
    private let isClosedSubject = CurrentValueSubject<Bool, Never>(false)
    private let scanQRSubject = PassthroughSubject<Void, Never>()
    
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
