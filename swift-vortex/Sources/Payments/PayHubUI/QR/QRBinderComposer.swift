//
//  QRBinderComposer.swift
//
//
//  Created by Igor Malyarov on 28.10.2024.
//

import Combine
import CombineSchedulers
import Foundation

public final class QRBinderComposer<Navigation, QR, QRResult> {
    
    private let microServices: MicroServices
    private let mainScheduler: AnySchedulerOf<DispatchQueue>
    private let interactiveScheduler: AnySchedulerOf<DispatchQueue>
    
    public init(
        microServices: MicroServices,
        mainScheduler: AnySchedulerOf<DispatchQueue>,
        interactiveScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.microServices = microServices
        self.mainScheduler = mainScheduler
        self.interactiveScheduler = interactiveScheduler
    }
    
    public typealias MicroServices = QRBinderComposerMicroServices<Navigation, QR, QRResult>
}

public extension QRBinderComposer {
    
    func compose() -> Domain.Binder {
        
        let composer = Domain.FlowDomain.Composer(
            microServices: .init(
                getNavigation: microServices.getNavigation
            ),
            scheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return .init(
            content: microServices.makeQR(),
            flow: composer.compose(),
            bind: microServices.bind
        )
    }
    
    typealias Domain = QRDomain<Navigation, QR, QRResult>
}
