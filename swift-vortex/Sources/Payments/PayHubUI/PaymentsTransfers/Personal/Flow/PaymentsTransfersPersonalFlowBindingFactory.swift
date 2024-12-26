//
//  PaymentsTransfersPersonalFlowBindingFactory.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import CombineSchedulers
import Foundation

public final class PaymentsTransfersPersonalFlowBindingFactory<QRNavigation> {
    
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
    
    func bindScanQR<Emitter>(
        emitter: Emitter,
        to receive: @escaping () -> Void,
        using witness: (Emitter) -> AnyPublisher<Void, Never>
    ) -> AnyCancellable {
        
        witness(emitter)
            .delay(for: delay, scheduler: scheduler)
            .sink { receive() }
    }
    
    func bindQRNavigation<Emitter>(
        emitter: Emitter,
        to receive: @escaping (QRNavigation) -> Void,
        using witness: (Emitter) -> AnyPublisher<QRNavigation, Never>
    ) -> AnyCancellable {
        
        witness(emitter)
            .delay(for: delay, scheduler: scheduler)
            .sink { receive($0) }
    }
}
