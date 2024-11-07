//
//  QRBinderTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import ForaTools
import PayHub
import PayHubUI
import XCTest

class QRBinderTests: XCTestCase {
    
    typealias NavigationComposer = QRBinderGetNavigationComposer<MixedPicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source>
    typealias NavigationComposerMicroServices = NavigationComposer.MicroServices
    
    typealias Navigation = QRNavigation<MixedPicker, Payments, QRFailure>
    
    typealias QRResult = QRModelResult<Operator, Provider, QRCode, QRMapping, Source>
    typealias Witnesses = QRDomain<Navigation, QR, QRResult>.Witnesses
    
    typealias MakeMixedPickerPayload = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMixedPicker = CallSpy<MakeMixedPickerPayload, MixedPicker>
    
    typealias MakePaymentsPayload = NavigationComposerMicroServices.MakePaymentsPayload
    typealias MakePayments = CallSpy<MakePaymentsPayload, Payments>
    
    typealias MakeQRFailure = CallSpy<QRCode, QRFailure>
    
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
    
    func makeMixed(
        first: OperatorProvider<Operator, Provider>? = nil,
        second: OperatorProvider<Operator, Provider>? = nil,
        tail: OperatorProvider<Operator, Provider>...
    ) -> MultiElementArray<OperatorProvider<Operator, Provider>> {
        
        return .init(first ?? .operator(makeOperator()), second ?? .provider(makeProvider()), tail)
    }
    
    func makeMakeMixedPickerPayload() -> MakeMixedPickerPayload {
        
        let (mixed, qrCode, qrMapping) = (makeMixed(), makeQRCode(), makeQRMapping())
        
        return .init(operators: mixed, qrCode: qrCode, qrMapping: qrMapping)
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
        
        case mixedPicker(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case qrFailure(ObjectIdentifier)
    }
    
    func equatable(
        _ navigation: Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .mixedPicker(node):
            return .mixedPicker(.init(node.model))
            
        case let .payments(node):
            return .payments(.init(node.model))
            
        case let .qrFailure(node):
            return .qrFailure(.init(node.model))
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
    
    final class Payments {
        
        private let isCloseSubject = CurrentValueSubject<Bool, Never>(false)
        
        var isClosed: AnyPublisher<Bool, Never> {
            
            isCloseSubject.eraseToAnyPublisher()
        }
        
        func close() {
            
            isCloseSubject.value = true
        }
        
        private let scanQRSubject = PassthroughSubject<Void, Never>()
        
        var scanQRPublisher: AnyPublisher<Void, Never> {
            
            scanQRSubject.eraseToAnyPublisher()
        }
        
        func scanQR() {
            
            scanQRSubject.send(())
        }
    }
    
    func makePayments() -> Payments {
        
        return .init()
    }
    
    final class QRFailure {
        
        private let scanQRSubject = PassthroughSubject<Void, Never>()
        
        var scanQRPublisher: AnyPublisher<Void, Never> {
            
            scanQRSubject.eraseToAnyPublisher()
        }
        
        func scanQR() {
            
            scanQRSubject.send(())
        }
    }
    
    func makeQRFailure() -> QRFailure {
        
        return .init()
    }
    
    final class MixedPicker {
        
        
    }
    
    func makeMixedPicker() -> MixedPicker {
        
        return .init()
    }
}
