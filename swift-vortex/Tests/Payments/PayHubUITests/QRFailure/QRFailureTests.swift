//
//  QRFailureTests.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

import Combine
import FlowCore
import PayHubUI
import XCTest

class QRFailureTests: XCTestCase {
    
    typealias Domain = QRFailureDomain<QRCode, QRFailure, CategoryPicker, DetailPayment>
    typealias CategoryPicker = ClosingScanQR
    typealias DetailPayment = ClosingScanQR
    
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
        
        typealias Event = FlowEvent<Select, Never>
        
        private let subject = PassthroughSubject<Event, Never>()
        
        var selectPublisher: AnyPublisher<Event, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ event: Event) {
            
            subject.send(event)
        }
        
        func emit(_ select: Select) {
            
            subject.send(.select(select))
        }
        
        func dismiss() {
            
        }
    }
    
    func makeQRFailure() -> QRFailure {
        
        return .init()
    }
    
    final class ClosingScanQR {
        
        // MARK: - close
        
        private let closeSubject = PassthroughSubject<Bool, Never>()
        
        var isClosedPublisher: AnyPublisher<Bool, Never> {
            
            closeSubject.eraseToAnyPublisher()
        }
        
        func close() {
            
            closeSubject.send(true)
        }
        
        // MARK: - scanQR
        
        private let subject = PassthroughSubject<Void, Never>()
        
        var scanQRPublisher: AnyPublisher<Void, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func scanQR() {
            
            subject.send(())
        }
    }
    
    func makeDetailPayment() -> ClosingScanQR {
        
        return .init()
    }
    
    func makeCategoryPicker() -> ClosingScanQR {
        
        return .init()
    }
    
    func equatable(
        _ navigation: Domain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .categoryPicker(node):
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
