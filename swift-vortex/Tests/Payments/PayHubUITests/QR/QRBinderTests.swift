//
//  QRBinderTests.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import VortexTools
import PayHub
import PayHubUI
import XCTest

class QRBinderTests: XCTestCase {
    
    typealias NavigationComposer = QRBinderGetNavigationComposer<ConfirmSberQR, MixedPicker, MultiplePicker, Operator, OperatorModel, Payments, Provider, QRCode, QRFailure, QRMapping, ServicePicker, Source>
    typealias FirstMicroServices = NavigationComposer.FirstMicroServices
    
    typealias Domain = QRNavigationDomain<ConfirmSberQR, MixedPicker, MultiplePicker, Operator, OperatorModel, Payments, Provider, QRCode, QRFailure, QRMapping, ServicePicker, Source>
    
    typealias Navigation = Domain.Navigation
    typealias Select = Domain.Select
    typealias QRResult = Select.QRResult
    
    typealias Witnesses = QRDomain<Navigation, QR, Select>.Witnesses
    
    typealias MakeConfirmSberQR = Spy<URL, ConfirmSberQR?>
    
    typealias MakeMixedPickerPayload = MixedQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMixedPicker = CallSpy<MakeMixedPickerPayload, MixedPicker>
    
    typealias MakeMultiplePickerPayload = MultipleQRResult<Operator, Provider, QRCode, QRMapping>
    typealias MakeMultiplePicker = CallSpy<MakeMultiplePickerPayload, MultiplePicker>
    
    typealias SinglePayload = PayHub.SinglePayload<Operator, QRCode, QRMapping>
    typealias MakeOperatorModel = CallSpy<SinglePayload, OperatorModel>
    
    typealias MakePaymentsPayload = PayHubUI.MakePaymentsPayload<QRCode, Source>
    typealias MakePayments = CallSpy<MakePaymentsPayload, Payments>
    
    typealias MakeQRFailure = CallSpy<QRCode?, QRFailure>
    
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
        
        case confirmSberQR(ObjectIdentifier)
        case failure(Failure)
        case outside(Outside)
        case mixedPicker(ObjectIdentifier)
        case multiplePicker(ObjectIdentifier)
        case operatorModel(ObjectIdentifier)
        case payments(ObjectIdentifier)
        case qrFailure(ObjectIdentifier)
        case servicePicker(ObjectIdentifier)
        
        enum Failure: Equatable {
            
            case sberQR(URL)
        }
        
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
            case let .confirmSberQR(node):
                return .confirmSberQR(.init(node.model))
                
            case let .failure(.sberQR(url)):
                return .failure(.sberQR(url))
                
            case let .mixedPicker(node):
                return .mixedPicker(.init(node.model))
                
            case let .multiplePicker(node):
                return .multiplePicker(.init(node.model))
                
            case let .operatorModel(operatorModel):
                return .operatorModel(.init(operatorModel))
                
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
        
        func dismiss() {
            
            callCount += 1
        }
    }
    
    func makeQR() -> QR {
        
        return .init()
    }
    
    func makeSinglePayload(
        `operator`: QRBinderTests.Operator? = nil,
        qrCode: QRBinderTests.QRCode? = nil,
        qrMapping: QRBinderTests.QRMapping? = nil
    ) -> SinglePayload {
        
        return .init(
            operator: `operator` ?? makeOperator(),
            qrCode: qrCode ?? makeQRCode(),
            qrMapping: qrMapping ?? makeQRMapping()
        )
    }
    
    final class OperatorModel {}
    
    func makeOperatorModel() -> OperatorModel {
        
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
        
        func publisher<T>(
            for keyPath: KeyPath<Event, T?>
        ) -> AnyPublisher<T, Never> {
            
            return eventSubject
                .compactMap { $0[keyPath: keyPath] }
                .eraseToAnyPublisher()
        }
        
        func emit(_ event: Event) {
            
            eventSubject.send(event)
        }
        
        private let eventSubject = PassthroughSubject<Event, Never>()
        
        enum Event {
            
            case addCompany
            case isClosed(Bool)
            case scanQR
            
            var addCompany: Void? {
                
                guard case .addCompany = self else { return nil }
                
                return ()
            }
            
            var isClosed: Bool? {
                
                guard case let .isClosed(value) = self else { return nil }
                
                return value
            }
            
            var scanQR: Void? {
                
                guard case .scanQR = self else { return nil }
                
                return ()
            }
        }
    }
    
    final class ConfirmSberQR {}
    
    func makeConfirmSberQR() -> ConfirmSberQR {
        
        return .init()
    }
    
    final class ServicePicker {
        
        func publisher(
            for keyPath: KeyPath<Event, Void?>
        ) -> AnyPublisher<Void, Never> {
            
            return eventSubject
                .compactMap { $0[keyPath: keyPath] }
                .eraseToAnyPublisher()
        }
        
        func emit(_ event: Event) {
            
            eventSubject.send(event)
        }
        
        // MARK: - Event
        
        private let eventSubject = PassthroughSubject<Event, Never>()
        
        enum Event {
            
            case goToChat, goToMain, goToPayments
            case scanQR
            
            var goToChat: Void? { self == .goToChat ? () : nil }
            var goToMain: Void? { self == .goToMain ? () : nil }
            var goToPayments: Void? { self == .goToPayments ? () : nil }
            var scanQR: Void? { self == .scanQR ? () : nil }
        }
        
        // MARK: - isLoading
        
        private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
        
        var isLoading: AnyPublisher<Bool, Never> {
            
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
