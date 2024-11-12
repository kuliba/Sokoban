//
//  MixedPicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.11.2024.
//

import Combine

final class MixedPicker {
    
    // MARK: - close
    
    private let isCloseSubject = CurrentValueSubject<Bool, Never>(false)
    
    var isClosedPublisher: AnyPublisher<Bool, Never> {
        
        isCloseSubject.eraseToAnyPublisher()
    }
    
    func close() {
        
        isCloseSubject.value = true
    }
    
    // MARK: - scanQR
    
    private let scanQRSubject = PassthroughSubject<Void, Never>()
    
    var scanQRPublisher: AnyPublisher<Void, Never> {
        
        scanQRSubject.eraseToAnyPublisher()
    }
    
    func scanQR() {
        
        scanQRSubject.send(())
    }
    
    
    // MARK: - addCompany
    
    private let addCompanySubject = PassthroughSubject<Void, Never>()
    
    var addCompanyPublisher: AnyPublisher<Void, Never> {
        
        addCompanySubject.eraseToAnyPublisher()
    }
    
    func addCompany() {
        
        addCompanySubject.send(())
    }
}
