//
//  Node+ContentViewDomain.Flow+preview.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

extension Publisher where Failure == Never {
    
    func emitNilThenValueWithDelay<Value>(
        delay: DispatchQueue.SchedulerTimeType.Stride,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> AnyPublisher<Value?, Never> where Output == Optional<Value> {
        
        self.compactMap { $0 }
            .prefix(1) // Take only the first value, safe to store forever
            .map { [Value?.none, $0] } // emit nil first
            .flatMap {
                
                $0.publisher.flatMap {
                    
                    Just($0)
                        .delay(for: $0 == nil ? 0 : delay, scheduler: scheduler) // emit real value with delay
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Node where Model == ContentViewDomain.Flow {
    
    typealias Delay = DispatchQueue.SchedulerTimeType.Stride
    
    static func preview(
        delay: Delay = .milliseconds(500),
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main,
        interactiveScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive)
    ) -> Self {
        
        let qrComposer: QRBinderComposer<QRNavigation, QRModel, QRResult> = .preview
        
        var cancellables = Set<AnyCancellable>()
        
        let composer = ContentViewDomain.Composer(
            getNavigation: { select, notify, completion in
                
                switch select {
                case let .qrNavigation(qrNavigation):
                    completion(.qrNavigation(qrNavigation))
                    
                case .scanQR:
                    let qr = qrComposer.compose()
                    
                    qr.flow.$state
                        .map(\.navigation)
                    // Takes only the first navigation value, safe to store forever
                    // Emit nil first to dismiss navigation
                    // Emit real navigation with delay
                        .emitNilThenValueWithDelay(delay: delay, scheduler: mainScheduler)
                        .sink { navigation in
                            
                            if let navigation {
                                notify(.select(.qrNavigation(navigation)))
                            } else {
                                notify(.dismiss)
                            }
                        }
                        .store(in: &cancellables)
                    
                    completion(.qr(qr))
                }
            },
            scheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return .init(model:composer.compose(), cancellables: cancellables)
    }
}
