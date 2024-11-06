//
//  QRFailureTests.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

import Combine
import XCTest

class QRFailureTests: XCTestCase {
    
    typealias Domain = QRFailureDomain<QRFailure, Categories, DetailPayment>
    typealias Select = Domain.Select
    
    struct QRFailure {
        
        let value: String
        private let subject = PassthroughSubject<Select, Never>()
        
        var selectPublisher: AnyPublisher<Select, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func receive() {
            
        }
    }
    
    func makeQRFailure(
        _ value: String = anyMessage()
    ) -> QRFailure {
        
        return .init(value: value)
    }
    
    struct Categories: Equatable {
        
        let value: String
    }
    
    func makeCategories(
        _ value: String = anyMessage()
    ) -> Categories {
        
        return .init(value: value)
    }
    
    struct DetailPayment: Equatable {
        
        let value: String
    }
    
    func makeDetailPayment(
        _ value: String = anyMessage()
    ) -> DetailPayment {
        
        return .init(value: value)
    }
}
