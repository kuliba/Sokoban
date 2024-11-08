//
//  QRBinderGetMappedNavigationComposer.swift
//
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import PayHub

public final class QRBinderGetMappedNavigationComposer<MixedPicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source> {
    
    private let microServices: MicroServices
    private let witnesses: Witnesses
    
    public init(
        microServices: MicroServices,
        witnesses: Witnesses
    ) {
        self.microServices = microServices
        self.witnesses = witnesses
    }
    
    public typealias MicroServices = QRBinderGetMappedNavigationComposerMicroServices<MixedPicker, Operator, Provider, QRCode, QRMapping, QRFailure>
    public typealias Witnesses = QRBinderGetMappedNavigationWitnesses<MixedPicker, QRFailure>
}

public extension QRBinderGetMappedNavigationComposer {
    
    func getNavigation(
        mapped: Mapped,
        notify: @escaping Notify,
        completion: @escaping (Navigation) -> Void
    ) {
        switch mapped {
        case let .missingINN(qrCode):
            let qrFailure = microServices.makeQRFailure(.missingINN(qrCode))
            completion(.qrNavigation(.qrFailure(.init(
                model: qrFailure,
                cancellables: bind(qrFailure, using: notify)
            ))))
            
        case let .mixed(mixed):
            let mixedPicker = microServices.makeMixedPicker(mixed)
            completion(.qrNavigation(.mixedPicker(.init(
                model: mixedPicker,
                cancellables: bind(mixedPicker, using: notify)
            ))))
            
        default:
            fatalError()
        }
    }
    
    typealias Domain = QRNavigationDomain<MixedPicker, Operator, Provider, Payments, QRCode, QRMapping, QRFailure, Source>
    typealias FlowDomain = Domain.FlowDomain
    
    typealias Notify = (FlowDomain.NotifyEvent) -> Void
    typealias Mapped = Domain.Select.QRMappedResult
    typealias Navigation = Domain.Navigation
}

// MARK: - bindings

private extension QRBinderGetMappedNavigationComposer {
    
    func bind(
        _ mixedPicker: MixedPicker,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let addCompany = witnesses.addCompany.mixedPicker(mixedPicker)
            .sink { notify(.select(.outside(.chat))) }
        
        let close = witnesses.isClosed.mixedPicker(mixedPicker)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = witnesses.scanQR.mixedPicker(mixedPicker)
            .sink { notify(.dismiss) }
        
        return [addCompany, close, scanQR]
    }
    
    func bind(
        _ qrFailure: QRFailure,
        using notify: @escaping Notify
    ) -> Set<AnyCancellable> {
        
        let close = witnesses.isClosed.qrFailure(qrFailure)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = witnesses.scanQR.qrFailure(qrFailure)
            .sink { notify(.dismiss) }
        
        return [close, scanQR]
    }
}
