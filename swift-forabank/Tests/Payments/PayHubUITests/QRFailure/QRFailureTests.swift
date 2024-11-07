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
    typealias Categories = ScanQR
    typealias DetailPayment = ScanQR
    
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
    
    final class ScanQR {
        
        private let subject = PassthroughSubject<Void, Never>()
        
        var scanQRPublisher: AnyPublisher<Void, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func scanQR() {
            
            subject.send(())
        }
    }
    
    func makeDetailPayment() -> ScanQR {
        
        return .init()
    }
    
    func makeCategories() -> ScanQR {
        
        return .init()
    }
    
    func equatable(
        _ navigation: Domain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .categories(node):
            return .categories(.init(node.model))
            
        case let .detailPayment(node):
            return .detailPayment(.init(node.model))
            
        case .scanQR:
            return .scanQR
        }
    }
    
    enum EquatableNavigation: Equatable {
        
        case categories(ObjectIdentifier)
        case detailPayment(ObjectIdentifier)
        case scanQR
    }
}
