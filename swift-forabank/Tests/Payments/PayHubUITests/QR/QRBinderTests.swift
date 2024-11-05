//
//  QRBinderTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import PayHub
import PayHubUI
import XCTest

class QRBinderTests: XCTestCase {
    
    typealias NavigationComposer = QRBinderGetNavigationComposer<Operator, Provider, Payments, QRCode, QRMapping, Source>
    
    typealias Navigation = QRNavigation<Payments>
    
    typealias QRResult = QRModelResult<Operator, Provider, QRCode, QRMapping, Source>
    typealias Witnesses = QRDomain<Navigation, QR, QRResult>.Witnesses
    
    typealias MakePaymentsPayload = QRBinderGetNavigationComposerMicroServices<Payments>.MakePaymentsPayload
    typealias MakePayments = CallSpy<MakePaymentsPayload, Payments>
    
    struct Operator: Equatable {
        
        let value: String
    }
    
    func makeOperator(
        _ value: String = anyMessage()
    ) -> Operator {
        
        return .init(value: value)
    }
    
    struct Provider: Equatable {
        
        let value: String
    }
    
    func makeProvider(
        _ value: String = anyMessage()
    ) -> Provider {
        
        return .init(value: value)
    }
    
    struct QRCode: Equatable {
        
        let value: String
    }
    
    func makeQRCode(
        _ value: String = anyMessage()
    ) -> QRCode {
        
        return .init(value: value)
    }
    
    struct QRMapping: Equatable {
        
        let value: String
    }
    
    func makeQRMapping(
        _ value: String = anyMessage()
    ) -> QRMapping {
        
        return .init(value: value)
    }
    
    struct Source: Equatable {
        
        let value: String
    }
    
    func makeSource(
        _ value: String = anyMessage()
    ) -> Source {
        
        return .init(value: value)
    }
    
    enum EquatableNavigation: Equatable {
        
        case payments(ObjectIdentifier)
    }
    
    func equatable(
        _ navigation: Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .payments(payments):
            return .payments(.init(payments))
        }
    }
    
    final class QR {
        
        private let subject = PassthroughSubject<QRResult, Never>()
        
        private(set) var callCount = 0
        
        var publisher: AnyPublisher<QRResult, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ value: QRResult) {
            
            self.subject.send(value)
        }
        
        func receive() {
            
            callCount += 1
        }
    }
    
    func makeQR() -> QR {
        
        return .init()
    }
    
    final class Payments {}
    
    func makePayments() -> Payments {
        
        return .init()
    }
}
