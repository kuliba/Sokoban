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
                        .compactMap { $0.navigation }
                        .prefix(1) // Take only the first navigation value, safe to store forever
                        .flatMap { navigation -> AnyPublisher<QRNavigation?, Never> in
                            
                            let nilPublisher = Just<QRNavigation?>(nil)
                            let delayedNavigationPublisher = Just<QRNavigation?>(navigation)
                                .delay(for: delay, scheduler: mainScheduler)
                            
                            return nilPublisher
                                .append(delayedNavigationPublisher)
                                .eraseToAnyPublisher()
                        }
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
