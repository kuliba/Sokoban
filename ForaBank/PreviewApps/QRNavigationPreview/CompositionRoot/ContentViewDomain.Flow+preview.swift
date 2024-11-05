//
//  ContentViewDomain.Flow+preview.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import CombineSchedulers
import Foundation
import PayHubUI

extension ContentViewDomain.Flow {
    
    static func preview(
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main,
        interactiveScheduler: AnySchedulerOf<DispatchQueue> = .global(qos: .userInteractive)
    ) -> ContentViewDomain.Flow {
        
        let qrComposer: QRBinderComposer<QRNavigation, QRModel, QRResult> = .preview(
            mainScheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        let composer = ContentViewDomain.Composer(
            getNavigation: { select, notify, completion in
                
                switch select {
                case .scanQR:
                    let qr = qrComposer.compose()
                    let close = qr.content.isClosedPublisher
                        .sink { if $0 { notify(.dismiss) }}
                    
                    completion(.qr(.init(model: qr, cancellable: close)))
                }
            },
            scheduler: mainScheduler,
            interactiveScheduler: interactiveScheduler
        )
        
        return composer.compose()
    }
}
