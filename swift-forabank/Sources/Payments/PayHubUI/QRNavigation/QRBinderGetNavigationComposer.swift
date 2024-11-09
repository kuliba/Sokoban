//
//  QRBinderGetNavigationComposer.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import PayHub

public final class QRBinderGetNavigationComposer<MixedPicker, MultiplePicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source, ServicePicker> {
    
    private let microServices: MicroServices
    private let witnesses: Witnesses
    
    public init(
        microServices: MicroServices,
        witnesses: Witnesses
    ) {
        self.microServices = microServices
        self.witnesses = witnesses
    }
    
    public typealias MicroServices = QRBinderGetNavigationComposerMicroServices<MixedPicker, MultiplePicker, Operator, Payments, Provider, QRCode, QRMapping, QRFailure, ServicePicker>
    public typealias Witnesses = QRBinderGetNavigationWitnesses<MixedPicker, MultiplePicker, Payments, QRFailure, ServicePicker>
}

public extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        select: Select,
        notify: @escaping Notify,
        completion: @escaping (Navigation) -> Void
    ) {
        switch select {
        case let .outside(outside):
            getNavigation(outside, notify, completion)
            
        case let .qrResult(qrResult):
            getNavigation(qrResult, notify, completion)
        }
    }
    
    typealias Domain = QRNavigationDomain<MixedPicker, MultiplePicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source, ServicePicker>
    typealias FlowDomain = Domain.FlowDomain
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    typealias Select = Domain.Select
    typealias Navigation = Domain.Navigation
}

private extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        _ outside: Select.Outside,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch outside {
        case .chat:
            completion(.outside(.chat))
        
        case .main:
            completion(.outside(.main))
        
        case .payments:
            completion(.outside(.payments))
        }
    }
    
    func getNavigation(
        _ qrResult: Select.QRResult,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch qrResult {
        case let .c2bSubscribeURL(url):
            let payments = microServices.makePayments(.c2bSubscribe(url))
            completion(.qrNavigation(.payments(bind(payments, using: notify))))
            
        case let .c2bURL(url):
            let payments = microServices.makePayments(.c2b(url))
            completion(.qrNavigation(.payments(bind(payments, using: notify))))
            
        case let .failure(qrCode):
            let qrFailure = microServices.makeQRFailure(.qrCode(qrCode))
            completion(.qrNavigation(.qrFailure(bind(qrFailure, using: notify))))
            
        case let .mapped(mapped):
            getNavigation(mapped, notify, completion)
            
        default:
            fatalError()
        }
    }
    
    typealias Mapped = QRMappedResult<Operator, Provider, QRCode, QRMapping, Source>
    
    func getNavigation(
        _ mapped: Mapped,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation) -> Void
    ) {
        switch mapped {
        case let .missingINN(qrCode):
            let qrFailure = microServices.makeQRFailure(.missingINN(qrCode))
            completion(.qrNavigation(.qrFailure(bind(qrFailure, using: notify))))
            
        case let .mixed(mixed):
            let mixedPicker = microServices.makeMixedPicker(mixed)
            completion(.qrNavigation(.mixedPicker(bind(mixedPicker, using: notify))))
            
        case let .multiple(multiple):
            let multiplePicker = microServices.makeMultiplePicker(multiple)
            completion(.qrNavigation(.multiplePicker(bind(multiplePicker, using: notify))))
            
        case let .none(qrCode):
            let payments = microServices.makePayments(.details(qrCode))
            completion(.qrNavigation(.payments(bind(payments, using: notify))))
            
        case let .provider(payload):
            let servicePicker = microServices.makeServicePicker(payload)
            completion(.qrNavigation(.servicePicker(.init(
                model: servicePicker,
                cancellables: bind(servicePicker, using: notify)
            ))))
            
        default:
            fatalError()
        }
    }
}

// MARK: - bindings

private extension QRBinderGetNavigationComposer {
    
    func bind(
        _ mixedPicker: MixedPicker,
        using notify: @escaping Notify
    ) -> Node<MixedPicker> {
        
        return .init(
            model: mixedPicker,
            cancellables: bind(
                mixedPicker,
                to: notify,
                addCompany: \.mixedPicker,
                isClosed: \.mixedPicker, scanQR: \.mixedPicker
            )
        )
    }
    
    func bind(
        _ multiplePicker: MultiplePicker,
        using notify: @escaping Notify
    ) -> Node<MultiplePicker> {
        
        return .init(
            model: multiplePicker,
            cancellables: bind(
                multiplePicker, 
                to: notify,
                addCompany: \.multiplePicker,
                isClosed: \.multiplePicker,
                scanQR: \.multiplePicker
            )
        )
    }
    
    func bind(
        _ payments: Payments,
        using notify: @escaping Notify
    ) -> Node<Payments> {
        
        return .init(
            model: payments,
            cancellables: bind(
                payments,
                to: notify,
                isClosed: \.payments,
                scanQR: \.payments
            )
        )
    }
    
    func bind(
        _ qrFailure: QRFailure,
        using notify: @escaping Notify
    ) -> Node<QRFailure> {
        
        return .init(
            model: qrFailure,
            cancellables: bind(
                qrFailure,
                to: notify,
                isClosed: \.qrFailure,
                scanQR: \.qrFailure
            )
        )
    }
    
    func bind(
        _ servicePicker: ServicePicker,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        return bind(servicePicker, to: notify, addCompany: \.servicePicker, goToMain: \.servicePicker, goToPayments: \.servicePicker, scanQR: \.servicePicker)
    }
    
    private typealias WitnessFunction<T, Value> = (T) -> AnyPublisher<Value, Never>
    private typealias WitnessKeyPath<T, Witness, Value> = KeyPath<Witness, WitnessFunction<T, Value>>
    
    private func bind<T>(
        _ object: T,
        to notify: @escaping Notify,
        addCompany addCompanyKeyPath: WitnessKeyPath<T, Witnesses.AddCompanyWitnesses, Void>? = nil,
        goToMain goToMainKeyPath: WitnessKeyPath<T, Witnesses.GoToMainWitnesses, Void>? = nil,
        goToPayments goToPaymentsKeyPath: WitnessKeyPath<T, Witnesses.GoToPaymentsWitnesses, Void>? = nil,
        isClosed isClosedKeyPath: WitnessKeyPath<T, Witnesses.IsClosedWitnesses, Bool>? = nil,
        scanQR scanQRKeyPath: WitnessKeyPath<T, Witnesses.ScanQRWitnesses, Void>? = nil
    ) -> Set<AnyCancellable> {
        
        var cancellables = Set<AnyCancellable>()
        
        if let addCompanyKeyPath {
            
            let witness = witnesses.addCompany[keyPath: addCompanyKeyPath]
            let chat = witness(object).sink { notify(.select(.outside(.chat))) }
            cancellables.insert(chat)
        }
        
        if let goToMainKeyPath {
            
            let witness = witnesses.goToMain[keyPath: goToMainKeyPath]
            let main = witness(object).sink { notify(.select(.outside(.main))) }
            cancellables.insert(main)
        }
        
        if let goToPaymentsKeyPath {
            
            let witness = witnesses.goToPayments[keyPath: goToPaymentsKeyPath]
            let payments = witness(object).sink { notify(.select(.outside(.payments))) }
            cancellables.insert(payments)
        }
        
        if let isClosedKeyPath {
            
            let witness = witnesses.isClosed[keyPath: isClosedKeyPath]
            let close = witness(object).sink { if $0 { notify(.dismiss) }}
            cancellables.insert(close)
        }
        
        if let scanQRKeyPath {
            
            let witness = witnesses.scanQR[keyPath: scanQRKeyPath]
            let scanQR = witness(object).sink { notify(.dismiss) }
            cancellables.insert(scanQR)
        }
        
        return cancellables
    }
}
