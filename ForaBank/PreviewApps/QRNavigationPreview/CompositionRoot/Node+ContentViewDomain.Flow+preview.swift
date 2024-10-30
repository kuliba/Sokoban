//
//  Node+ContentViewDomain.Flow+preview.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import Foundation
import PayHubUI

extension Node where Model == ContentViewDomain.Flow {
    
    static var preview: Self {
        
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
                        .prefix(1) // Take only the first navigation value, safe to store
                        .flatMap { navigation -> AnyPublisher<QRNavigation?, Never> in
                            
                            let nilPublisher = Just<QRNavigation?>(nil)
                            let delayedNavigationPublisher = Just<QRNavigation?>(navigation)
                                .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
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
            scheduler: .main,
            interactiveScheduler: .global(qos: .userInteractive)
        )
        
        return .init(model:composer.compose(), cancellables: cancellables)
    }
}
