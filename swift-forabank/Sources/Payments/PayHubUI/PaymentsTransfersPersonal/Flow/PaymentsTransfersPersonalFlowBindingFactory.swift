//
//  PaymentsTransfersPersonalFlowBindingFactory.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import CombineSchedulers
import Foundation

public final class PaymentsTransfersPersonalFlowBindingFactory<QRNavigation, ScanQR> {
    
    private let delay: Delay
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        delay: Delay = .milliseconds(100),
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.delay = delay
        self.scheduler = scheduler
    }
    
    public typealias Delay = DispatchQueue.SchedulerTimeType.Stride
}

public extension PaymentsTransfersPersonalFlowBindingFactory {
    
    typealias Domain = PaymentsTransfersPersonalDomain<QRNavigation, ScanQR>
    
    func bindScanQR<Emitter>(
        emitter: Emitter,
        to receiver: @escaping (Domain.NotifyEvent) -> Void,
        using witness: (Emitter) -> AnyPublisher<Void, Never>
    ) -> AnyCancellable {
        
        witness(emitter)
            .delay(for: delay, scheduler: scheduler)
            .sink { receiver(.select(.scanQR)) }
    }
    
    func bindQRNavigation<Emitter>(
        emitter: Emitter,
        to receiver: @escaping (Domain.NotifyEvent) -> Void,
        using witness: (Emitter) -> AnyPublisher<QRNavigation, Never>
    ) -> AnyCancellable {
        
        witness(emitter)
            .delay(for: delay, scheduler: scheduler)
            .sink { receiver(.select(.qrNavigation($0))) }
    }
}
