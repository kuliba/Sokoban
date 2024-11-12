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

public final class QRFailureBinderComposer<QRCode, QRFailure, CategoryPicker, DetailPayment> {
    
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
    
    public typealias MicroServices = QRFailureBinderComposerMicroServices<QRCode, QRFailure, CategoryPicker, DetailPayment>
    
    public typealias IsClosedWitnesses = QRFailureIsClosedWitnesses<CategoryPicker, DetailPayment>
    
    public typealias QRFailureScanQRWitnesses = PayHubUI.QRFailureScanQRWitnesses<CategoryPicker, DetailPayment>
    
    public typealias ContentFlowWitnesses = PayHubUI.ContentFlowWitnesses<QRFailure, Domain.Flow, Domain.Select, Domain.Navigation>
    public typealias Domain = QRFailureDomain<QRCode, QRFailure, CategoryPicker, DetailPayment>
}

public extension QRFailureBinderComposer {
    
    func compose(with qrCode: QRCode?) -> Domain.Binder {
        
        let factory = ContentFlowBindingFactory(
            delay: delay,
            scheduler: schedulers.main
        )
        
        let composer = Domain.FlowComposer(
            delay: delay,
            getNavigation: getNavigation,
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
    
    func getNavigation(
        select: Domain.Select,
        notify: @escaping Domain.Notify,
        completion: @escaping (Domain.Navigation) -> Void
    ) {
        switch select {
        case let .payWithDetails(qrCode):
            let payment = microServices.makeDetailPayment(qrCode)
            completion(.detailPayment(.init(
                model: payment,
                cancellables: bind(payment, using: notify)
            )))
            
        case let .search(qrCode):
            let categoryPicker = microServices.makeCategoryPicker(qrCode)
            completion(.categoryPicker(.init(
                model: categoryPicker,
                cancellables: bind(categoryPicker, using: notify)
            )))
            
        case .scanQR:
            completion(.scanQR)
        }
    }
}

// MARK: - bindings

private extension QRFailureBinderComposer {
    
    func bind(
        _ categoryPicker: CategoryPicker,
        using notify: @escaping Domain.Notify
    ) -> Set<AnyCancellable> {
        
        let close = isClosedWitnesses.categoryPicker(categoryPicker)
            .sink { if $0 { notify(.dismiss) }}
        
        let scanQR = scanQRWitnesses.categoryPicker(categoryPicker)
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
