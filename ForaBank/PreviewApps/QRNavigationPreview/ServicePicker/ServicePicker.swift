//
//  ServicePicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.11.2024.
//

import Combine

final class ServicePicker {
    
    // MARK: - addCompany
    
    private let addCompanySubject = PassthroughSubject<Void, Never>()
    
    var addCompanyPublisher: AnyPublisher<Void, Never> {
        
        addCompanySubject.eraseToAnyPublisher()
    }
    
    func addCompany() {
        
        addCompanySubject.send(())
    }
    
    // MARK: - goToMain
    
    private let goToMainSubject = PassthroughSubject<Void, Never>()
    
    var goToMainPublisher: AnyPublisher<Void, Never> {
        
        goToMainSubject.eraseToAnyPublisher()
    }
    
    func goToMain() {
        
        goToMainSubject.send(())
    }
}
