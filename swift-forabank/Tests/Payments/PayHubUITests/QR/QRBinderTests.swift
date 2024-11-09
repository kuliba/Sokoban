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
    
    typealias _NavigationComposer = _QRBinderGetNavigationComposer<_QRResult, _QRNavigation>
    
    struct _QRResult: Equatable {
        
        let value: String
    }
    
    func make_QRResult(
        _ value: String = anyMessage()
    ) -> _QRResult {
        
        return .init(value: value)
    }
    
    struct _QRNavigation: Equatable {
        
        let value: String
    }
    
    func make_QRNavigation(
        _ value: String = anyMessage()
    ) -> _QRNavigation {
        
        return .init(value: value)
    }
    
    typealias MappedNavigationComposer = _QRBinderGetMappedNavigationComposer<MixedPicker, MultiplePicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source, ServicePicker>
    typealias MappedNavigationComposerMicroServices = MappedNavigationComposer.MicroServices
    
    typealias NavigationComposer = QRBinderGetNavigationComposer<MixedPicker, MultiplePicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source, ServicePicker>
    typealias NavigationComposerMicroServices = NavigationComposer.MicroServices
    
    typealias Domain = QRNavigationDomain<MixedPicker, MultiplePicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source, ServicePicker>
    
    typealias Navigation = Domain.Navigation
    typealias Select = Domain.Select
    typealias QRResult = Select.QRResult
    
    typealias Witnesses = QRDomain<Navigation, QR, Select>.Witnesses
    
    typealias MakeMixedPickerPayload = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMixedPicker = CallSpy<MakeMixedPickerPayload, MixedPicker>
    
    typealias MakeMultiplePickerPayload = MultipleQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMultiplePicker = CallSpy<MakeMultiplePickerPayload, MultiplePicker>
    
    typealias MakePaymentsPayload = NavigationComposerMicroServices.MakePaymentsPayload
    typealias MakePayments = CallSpy<MakePaymentsPayload, Payments>
    
    typealias MakeQRFailure = CallSpy<QRCodeDetails<QRCode>, QRFailure>
    
    typealias MakeServicePicker = CallSpy<ProviderPayload, ServicePicker>
    
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
    
    typealias ProviderPayload = PayHub.ProviderPayload<Provider, QRCode, QRMapping>
    
    func makeProviderPayload(
        provider: Provider? = nil,
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil
    ) -> ProviderPayload {
        
        return .init(
            provider: provider ?? makeProvider(),
            qrCode: qrCode ?? makeQRCode(),
            qrMapping: qrMapping ?? makeQRMapping()
        )
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
    
    func makeMultiple(
        first: Operator? = nil,
        second: Operator? = nil,
        tail: Operator...
    ) -> MultiElementArray<Operator> {
        
        return .init(first ?? makeOperator(), second ?? makeOperator(), tail)
    }
    
    func makeMakeMultiplePickerPayload(
        operators: MultipleQRResult<Operator, Provider, QRCode, QRMapping>.MultipleOperators? = nil,
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil
    ) -> MakeMultiplePickerPayload {
        
        return .init(
            operators: operators ?? makeMultiple(),
            qrCode: qrCode ?? makeQRCode(),
            qrMapping: qrMapping ?? makeQRMapping()
        )
    }
    
    struct Source: Equatable {
        
        let value: String
    }
    
    func makeSource(
        _ value: String = anyMessage()
    ) -> Source {
        
        return .init(value: value)
    }
    
    func equatable(
        _ select: Select
    ) -> EquatableSelect {
        
        switch select {
        case .outside(.chat):
            return .outside(.chat)
            
        case .outside(.main):
            return .outside(.main)
            
        case .outside(.payments):
            return .outside(.payments)
            
        case let .qrResult(qrResult):
            return .qrResult(qrResult)
        }
    }
    
    enum EquatableSelect: Equatable {
        
        case outside(Outside)
        case qrResult(QRResult)

        enum Outside: Equatable {
         
            case chat, main, payments
        }
    }
    
    func equatable(
        _ event: NavigationComposer.FlowDomain.NotifyEvent
    ) -> EquatableNotifyEvent {
        
        switch event {
        case .dismiss:
            return .dismiss
            
        case let .select(select):
            switch select {
            case .outside(.chat):
                return .outside(.chat)
                
            case .outside(.main):
                return .outside(.main)
                
            case .outside(.payments):
                return .outside(.payments)
                
            case let .qrResult(qrResult):
                return .qrResult(qrResult)
            }
        }
    }
    
    enum EquatableNotifyEvent: Equatable {
        
        case dismiss
        case outside(Outside)
        case qrResult(QRResult)

        enum Outside: Equatable {
         
            case chat, main, payments
        }
    }
    
    enum EquatableNavigation: Equatable {
        
        case outside(Outside)
        case mixedPicker(ObjectIdentifier)
        case multiplePicker(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case qrFailure(ObjectIdentifier)
        case servicePicker(ObjectIdentifier)
        
        enum Outside: Equatable {
            
            case chat, main, payments
        }
    }
    
    func equatable(
        _ navigation: Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .outside(.chat):
            return .outside(.chat)
            
        case .outside(.main):
            return .outside(.main)
            
        case .outside(.payments):
            return .outside(.payments)
            
        case let .qrNavigation(qrNavigation):
            switch qrNavigation {
            case let .mixedPicker(node):
                return .mixedPicker(.init(node.model))
                
            case let .multiplePicker(node):
                return .multiplePicker(.init(node.model))
                
            case let .payments(node):
                return .payments(.init(node.model))
                
            case let .qrFailure(node):
                return .qrFailure(.init(node.model))
                
            case let .servicePicker(node):
                return .servicePicker(.init(node.model))
            }
        }
    }
    
    final class QR {
        
        private let subject = PassthroughSubject<Select, Never>()
        
        private(set) var callCount = 0
        
        var publisher: AnyPublisher<Select, Never> {
            
            subject.eraseToAnyPublisher()
        }
        
        func emit(_ value: Select) {
            
            self.subject.send(value)
        }
        
        func receive() {
            
            callCount += 1
        }
    }
    
    func makeQR() -> QR {
        
        return .init()
    }
    
    typealias Payments = Mock
    
    func makePayments() -> Payments {
        
        return .init()
    }
    
    typealias QRFailure = Mock
    
    func makeQRFailure() -> QRFailure {
        
        return .init()
    }
    
    typealias MixedPicker = Mock
    
    func makeMixedPicker() -> MixedPicker {
        
        return .init()
    }
    
    typealias MultiplePicker = Mock
    
    func makeMultiplePicker() -> MultiplePicker {
        
        return .init()
    }
    
    final class Mock {
        
        // MARK: - close
        
        private let isClosedSubject = CurrentValueSubject<Bool, Never>(false)
        
        var isClosed: AnyPublisher<Bool, Never> {
            
            isClosedSubject.eraseToAnyPublisher()
        }
        
        func close(_ input: Bool = true) {
            
            isClosedSubject.send(input)
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
    
    final class ServicePicker {
        
        func publisher(
            for keyPath: KeyPath<Event, Void?>
        ) -> AnyPublisher<Void, Never> {
            
            return eventSubject
                .compactMap { $0[keyPath: keyPath] }
                .eraseToAnyPublisher()
        }
        
        func addCompany() { eventSubject.send(.goToChat) }
        func goToMain() { eventSubject.send(.goToMain) }
        func goToPayments() { eventSubject.send(.goToPayments) }
        
        // MARK: - Event
        
        private let eventSubject = PassthroughSubject<Event, Never>()
        
        enum Event {
            
            case goToChat, goToMain, goToPayments
            
            var goToChat: Void? { self == .goToChat ? () : nil }
            var goToMain: Void? { self == .goToMain ? () : nil }
            var goToPayments: Void? { self == .goToPayments ? () : nil }
        }
        
        // MARK: - isLoading
        
        private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
        
        var isClosed: AnyPublisher<Bool, Never> {
            
            isLoadingSubject.eraseToAnyPublisher()
        }
        
        func isLoading(_ input: Bool) {
            
            isLoadingSubject.send(input)
        }
    }
    
    func makeServicePicker() -> ServicePicker {
        
        return .init()
    }
}
