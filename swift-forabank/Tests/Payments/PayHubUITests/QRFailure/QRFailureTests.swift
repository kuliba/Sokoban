//
//  QRFailureTests.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

import Combine
import PayHubUI
import XCTest

class QRFailureTests: XCTestCase {
    
    typealias Domain = QRFailureDomain<QRCode, QRFailure, Categories, DetailPayment>
    typealias Select = Domain.Select
    
    struct QRCode: Equatable {
        
        let value: String
    }
    
    func makeQRCode(
        _ value: String = anyMessage()
    ) -> QRCode {
        
        return .init(value: value)
    }
    
    struct QRFailure {
        
        private let subject = PassthroughSubject<Select, Never>()
        
        var selectPublisher: AnyPublisher<Select, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ select: Select) {
            
            subject.send(select)
        }
        
        func receive() {
            
        }
    }
    
    func makeQRFailure() -> QRFailure {
        
        return .init()
    }
    
    struct Categories: Equatable {
        
        let value: String
    }
    
    func makeCategories(
        _ value: String = anyMessage()
    ) -> Categories {
        
        return .init(value: value)
    }
    
    final class DetailPayment{
        
        private let subject = PassthroughSubject<Void, Never>()
        
        var scanQRPublisher: AnyPublisher<Void, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func scanQR() {
            
            subject.send(())
        }
    }
    
    func makeDetailPayment() -> DetailPayment {
        
        return .init()
    }
    
    func equatable(
        _ navigation: Domain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .categories(.failure):
            return .categories(.failure(.init()))
            
        case let .categories(.success(categories)):
            return .categories(.success(categories))
            
        case let .detailPayment(node):
            return .detailPayment(.init(node.model))
            
        case .scanQR:
            return .scanQR
        }
    }
    
    enum EquatableNavigation: Equatable {
        
        case categories(Result<Categories, CategoriesFailure>)
        case detailPayment(ObjectIdentifier)
        case scanQR
    }
    
    struct CategoriesFailure: Error, Equatable {}
}
