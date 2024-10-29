//
//  ContentViewDomain.Flow+preview.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import Combine
import Foundation
import PayHubUI

extension ContentViewDomain.Flow {
    
    static var preview: ContentViewDomain.Flow {
        
        let qrComposer: QRBinderComposer<QRNavigation, QRModel, QRResult> = .preview
        
        let composer = ContentViewDomain.Composer(
            getNavigation: { select, notify, completion in
                
                switch select {
                case let .qrNavigation(qrNavigation):
                    completion(.qrNavigation(qrNavigation))
                    
                case .scanQR:
                    let qr = qrComposer.compose()
                    let cancellable = qr.flow.$state
                        .compactMap { $0.navigation }
                        .delay(for: .milliseconds(100), scheduler: DispatchQueue.main)
                        .sink { notify(.select(.qrNavigation($0))) }
                    
                    completion(.qr(Node(model: qr, cancellable: cancellable)))
                }
            },
            scheduler: .main,
            interactiveScheduler: .global(qos: .userInteractive)
        )
        
        return composer.compose()
    }
}
