//
//  QRBinderGetNavigationComposer.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import PayHub

public final class QRBinderGetNavigationComposer<MixedPicker, MultiplePicker, Operator, OperatorModel, Payments, Provider, QRCode, QRFailure, QRMapping, ServicePicker, Source> {
    
    private let microServices: MicroServices
    private let witnesses: Witnesses
    
    public init(
        microServices: MicroServices,
        witnesses: Witnesses
    ) {
        self.microServices = microServices
        self.witnesses = witnesses
    }
    
    public typealias MicroServices = QRBinderGetNavigationComposerMicroServices<MixedPicker, MultiplePicker, Operator, OperatorModel, Payments, Provider, QRCode, QRFailure, QRMapping, ServicePicker, Source>
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
            getNavigation(outside, notify) { completion(.outside($0)) }
            
        case let .qrResult(qrResult):
            getNavigation(qrResult, notify) { completion(.qrNavigation($0)) }
        }
    }
    
    typealias Domain = QRNavigationDomain<MixedPicker, MultiplePicker, Operator, OperatorModel, Payments, Provider, QRCode, QRFailure, QRMapping, ServicePicker, Source>
    
    typealias FlowDomain = Domain.FlowDomain
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    typealias Select = Domain.Select
    typealias Navigation = Domain.Navigation
}

private extension QRBinderGetNavigationComposer {
    
    func getNavigation(
        _ outside: Select.Outside,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation.Outside) -> Void
    ) {
        switch outside {
        case .chat:     completion(.chat)
        case .main:     completion(.main)
        case .payments: completion(.payments)
        }
    }
    
    func getNavigation(
        _ qrResult: Select.QRResult,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation.QRNavigation) -> Void
    ) {
        switch qrResult {
        case let .c2bSubscribeURL(url):
            let payments = microServices.makePayments(.c2bSubscribe(url))
            completion(.payments(bind(payments, to: notify)))
            
        case let .c2bURL(url):
            let payments = microServices.makePayments(.c2b(url))
            completion(.payments(bind(payments, to: notify)))
            
        case let .failure(qrCode):
            let qrFailure = microServices.makeQRFailure(qrCode)
            completion(.qrFailure(bind(qrFailure, to: notify)))
            
        case let .mapped(mapped):
            getNavigation(mapped, notify, completion)
            
        case let .sberQR(url):
            microServices.makeConfirmSberQR(url) { _ in
                
                completion(.failure(.sberQR(url)))
            }
            
        case .url:
            let qrFailure = microServices.makeQRFailure(nil)
            completion(.qrFailure(bind(qrFailure, to: notify)))
            
        case .unknown:
            let qrFailure = microServices.makeQRFailure(nil)
            completion(.qrFailure(bind(qrFailure, to: notify)))
        }
    }
    
    typealias Mapped = QRMappedResult<Operator, Provider, QRCode, QRMapping, Source>
    
    func getNavigation(
        _ mapped: Mapped,
        _ notify: @escaping Notify,
        _ completion: @escaping (Navigation.QRNavigation) -> Void
    ) {
        switch mapped {
        case let .missingINN:
            let qrFailure = microServices.makeQRFailure(nil)
            completion(.qrFailure(bind(qrFailure, to: notify)))
            
        case let .mixed(mixed):
            let mixedPicker = microServices.makeMixedPicker(mixed)
            completion(.mixedPicker(bind(mixedPicker, to: notify)))
            
        case let .multiple(multiple):
            let multiplePicker = microServices.makeMultiplePicker(multiple)
            completion(.multiplePicker(bind(multiplePicker, to: notify)))
            
        case let .none(qrCode):
            let payments = microServices.makePayments(.details(qrCode))
            completion(.payments(bind(payments, to: notify)))
            
        case let .provider(payload):
            let servicePicker = microServices.makeServicePicker(payload)
            completion(.servicePicker(bind(servicePicker, to: notify)))
            
        case let .single(payload):
            let operatorModel = microServices.makeOperatorModel(payload)
            completion(.operatorModel(operatorModel))
            
        case let .source(source):
            let payments = microServices.makePayments(.source(source))
            completion(.payments(bind(payments, to: notify)))
        }
    }
}

// MARK: - bindings

private extension QRBinderGetNavigationComposer {
    
    func bind(
        _ mixedPicker: MixedPicker,
        to notify: @escaping Notify
    ) -> Node<MixedPicker> {
        
        return bind(mixedPicker, to: notify, with: .forMixedPicker())
    }
    
    func bind(
        _ multiplePicker: MultiplePicker,
        to notify: @escaping Notify
    ) -> Node<MultiplePicker> {
        
        return bind(multiplePicker, to: notify, with: .forMultiplePicker())
    }
    
    func bind(
        _ payments: Payments,
        to notify: @escaping Notify
    ) -> Node<Payments> {
        
        return bind(payments, to: notify, with: .forPayments())
    }
    
    func bind(
        _ qrFailure: QRFailure,
        to notify: @escaping Notify
    ) -> Node<QRFailure> {
        
        return bind(qrFailure, to: notify, with: .forQRFailure())
    }
    
    func bind(
        _ servicePicker: ServicePicker,
        to notify: @escaping Notify
    ) -> Node<ServicePicker> {
        
        return bind(servicePicker, to: notify, with: .forServicePicker())
    }
}

// MARK: - Helpers

private extension QRBinderGetNavigationComposer {
    
    func bind<Model>(
        _ model: Model,
        to notify: @escaping Notify,
        with parameters: BindParameters<Model>
    ) -> Node<Model> {
        
        return .init(
            model: model,
            cancellables: bind(model, to: notify, with: parameters)
        )
    }
    
    struct BindParameters<T> {
        
        var addCompany: VoidWitnessKeyPath<T, Witnesses.AddCompanyWitnesses>? = nil
        var goToMain: VoidWitnessKeyPath<T, Witnesses.GoToMainWitnesses>? = nil
        var goToPayments: VoidWitnessKeyPath<T, Witnesses.GoToPaymentsWitnesses>? = nil
        var isClosed: BoolWitnessKeyPath<T, Witnesses.IsClosedWitnesses>? = nil
        var scanQR: VoidWitnessKeyPath<T, Witnesses.ScanQRWitnesses>? = nil
        
        typealias VoidWitnessKeyPath<V, Witness> = WitnessKeyPath<V, Witness, Void>
        typealias BoolWitnessKeyPath<V, Witness> = WitnessKeyPath<V, Witness, Bool>
        typealias WitnessKeyPath<V, Witness, Value> = KeyPath<Witness, WitnessFunction<V, Value>>
        typealias WitnessFunction<V, Value> = (V) -> AnyPublisher<Value, Never>
        
        static func forMixedPicker() -> BindParameters<MixedPicker> {
            
            return .init(
                addCompany: \.mixedPicker,
                isClosed: \.mixedPicker,
                scanQR: \.mixedPicker
            )
        }
        
        static func forMultiplePicker() -> BindParameters<MultiplePicker> {
            
            return .init(
                addCompany: \.multiplePicker,
                isClosed: \.multiplePicker,
                scanQR: \.multiplePicker
            )
        }
        
        static func forPayments() -> BindParameters<Payments> {
            
            return .init(
                isClosed: \.payments,
                scanQR: \.payments
            )
        }
        
        static func forQRFailure() -> BindParameters<QRFailure> {
            
            return .init(
                isClosed: \.qrFailure,
                scanQR: \.qrFailure
            )
        }
        
        static func forServicePicker() -> BindParameters<ServicePicker> {
            
            return .init(
                addCompany: \.servicePicker,
                goToMain: \.servicePicker,
                goToPayments: \.servicePicker,
                scanQR: \.servicePicker
            )
        }
    }
    
    func bind<T>(
        _ object: T,
        to notify: @escaping Notify,
        with parameters: BindParameters<T>
    ) -> Set<AnyCancellable> {
        
        var cancellables = Set<AnyCancellable>()
        
        if let addCompanyKeyPath = parameters.addCompany {
            
            let witness = witnesses.addCompany[keyPath: addCompanyKeyPath]
            let chat = witness(object).sink { notify(.select(.outside(.chat))) }
            cancellables.insert(chat)
        }
        
        if let goToMainKeyPath = parameters.goToMain {
            
            let witness = witnesses.goToMain[keyPath: goToMainKeyPath]
            let main = witness(object).sink { notify(.select(.outside(.main))) }
            cancellables.insert(main)
        }
        
        if let goToPaymentsKeyPath = parameters.goToPayments {
            
            let witness = witnesses.goToPayments[keyPath: goToPaymentsKeyPath]
            let payments = witness(object).sink { notify(.select(.outside(.payments))) }
            cancellables.insert(payments)
        }
        
        if let isClosedKeyPath = parameters.isClosed {
            
            let witness = witnesses.isClosed[keyPath: isClosedKeyPath]
            let close = witness(object).sink { if $0 { notify(.dismiss) }}
            cancellables.insert(close)
        }
        
        if let scanQRKeyPath = parameters.scanQR {
            
            let witness = witnesses.scanQR[keyPath: scanQRKeyPath]
            let scanQR = witness(object).sink { notify(.dismiss) }
            cancellables.insert(scanQR)
        }
        
        return cancellables
    }
}
