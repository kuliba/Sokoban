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
    private let scanQRWitnesses: QRFailureScanQRWitnesses<DetailPayment>
    private let witnesses: Witnesses
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        delay: Delay,
        microServices: MicroServices,
        scanQRWitnesses: QRFailureScanQRWitnesses<DetailPayment>,
        witnesses: Witnesses,
        scheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.delay = delay
        self.microServices = microServices
        self.scanQRWitnesses = scanQRWitnesses
        self.witnesses = witnesses
        self.scheduler = scheduler
        self.interactiveScheduler = interactiveScheduler
    }
    
    public typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    public typealias MicroServices = QRFailureBinderComposerMicroServices<QRCode, QRFailure, Categories, DetailPayment>
    
    public typealias Witnesses = ContentFlowWitnesses<QRFailure, Domain.Flow, Domain.Select, Domain.Navigation>
    public typealias Domain = QRFailureDomain<QRCode, QRFailure, Categories, DetailPayment>
}

public extension QRFailureBinderComposer {
    
    func compose(qrCode: QRCode) -> Domain.Binder {
        
        let factory = ContentFlowBindingFactory(delay: delay, scheduler: scheduler)
        let composer = Domain.FlowComposer(
            getNavigation: { [weak self] select, notify, completion in
                
                guard let self else { return }
                
                switch select {
                case .scanQR:
                    completion(.scanQR)
                    
                case let .payWithDetails(qrCode):
                    let payment = microServices.makeDetailPayment(qrCode)
                    let cancellable = scanQRWitnesses.detailPayment(payment)
                        .sink { notify(.select(.scanQR)) }
                    
                    completion(.detailPayment(.init(model: payment, cancellable: cancellable)))
                    
                case let .search(qrCode):
                    let categories = microServices.makeCategories(qrCode)
                    completion(.categories(.init {
                        
                        try categories.get(orThrow: MakeCategoriesFailure())
                    }))
                }
            },
            scheduler: scheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return .init(
            content: microServices.makeQRFailure(qrCode),
            flow: composer.compose(),
            bind: factory.bind(with: witnesses)
        )
    }
    
    struct MakeCategoriesFailure: Error {}
}
