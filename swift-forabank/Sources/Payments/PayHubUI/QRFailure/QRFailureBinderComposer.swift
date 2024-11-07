//
//  QRFailureBinderComposer.swift
//
//
//  Created by Igor Malyarov on 06.11.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHub

public final class QRFailureBinderComposer<QRCode, QRFailure, Categories, DetailPayment> {
    
    private let delay: Delay
    private let microServices: MicroServices
    private let contentFlowWitnesses: ContentFlowWitnesses
    private let isClosedWitnesses: IsClosedWitnesses
    private let scanQRWitnesses: QRFailureScanQRWitnesses
    private let schedulers: Schedulers
    
    public init(
        delay: Delay,
        microServices: MicroServices,
        contentFlowWitnesses: ContentFlowWitnesses,
        isClosedWitnesses: IsClosedWitnesses,
        scanQRWitnesses: QRFailureScanQRWitnesses,
        schedulers: Schedulers
    ) {
        self.delay = delay
        self.microServices = microServices
        self.contentFlowWitnesses = contentFlowWitnesses
        self.isClosedWitnesses = isClosedWitnesses
        self.scanQRWitnesses = scanQRWitnesses
        self.schedulers = schedulers
    }
    
    public typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    public typealias MicroServices = QRFailureBinderComposerMicroServices<QRCode, QRFailure, Categories, DetailPayment>
    
    public typealias IsClosedWitnesses = QRFailureIsClosedWitnesses<Categories, DetailPayment>
    
    public typealias QRFailureScanQRWitnesses = PayHubUI.QRFailureScanQRWitnesses<Categories, DetailPayment>
    
    public typealias ContentFlowWitnesses = PayHubUI.ContentFlowWitnesses<QRFailure, Domain.Flow, Domain.Select, Domain.Navigation>
    public typealias Domain = QRFailureDomain<QRCode, QRFailure, Categories, DetailPayment>
}

public extension QRFailureBinderComposer {
    
    func compose(qrCode: QRCode) -> Domain.Binder {
        
        let factory = ContentFlowBindingFactory(delay: delay, scheduler: schedulers.main)
        
        let composer = Domain.FlowComposer(
            getNavigation: { [weak self] select, notify, completion in
                
                guard let self else { return }
                
                switch select {
                case let .payWithDetails(qrCode):
                    let payment = microServices.makeDetailPayment(qrCode)
                    completion(.detailPayment(.init(
                        model: payment,
                        cancellables: bind(payment, using: notify)
                    )))
                    
                case let .search(qrCode):
                    let categories = microServices.makeCategories(qrCode)
                    completion(.categories(.init(
                        model: categories,
                        cancellables: bind(categories, using: notify)
                    )))
                    
                case .scanQR:
                    completion(.scanQR)
                }
            },
            scheduler: schedulers.main,
            interactiveScheduler: schedulers.interactive
        )
        
        return .init(
            content: microServices.makeQRFailure(qrCode),
            flow: composer.compose(),
            bind: factory.bind(with: contentFlowWitnesses)
        )
    }
}

private extension QRFailureBinderComposer {
    
    func bind(
        _ categories: Categories,
        using notify: @escaping Domain.Notify
    ) -> Set<AnyCancellable> {
        
        let close = isClosedWitnesses.categories(categories)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = scanQRWitnesses.categories(categories)
            .sink { notify(.select(.scanQR)) }
        
        return [close, scanQR]
    }
    
    func bind(
        _ detailPayment: DetailPayment,
        using notify: @escaping Domain.Notify
    ) -> Set<AnyCancellable> {
        
        let close = isClosedWitnesses.detailPayment(detailPayment)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = scanQRWitnesses.detailPayment(detailPayment)
            .sink { notify(.select(.scanQR)) }
        
        return [close, scanQR]
    }
}
