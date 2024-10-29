//
//  ContentViewDomain.Flow+preview.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import PayHubUI

extension ContentViewDomain.Flow {
    
    static var preview: ContentViewDomain.Flow {
        
        let qrComposer = QRBinderComposer<QRNavigation, QRModel, QRResult>.preview
        
        let composer = ContentViewDomain.Composer(
            microServices: .init(
                getNavigation: { select, notify, completion in
                    
                    switch select {
                    case .scanQR:
                        completion(.qr(qrComposer.compose()))
                    }
                }
            ),
            scheduler: .main,
            interactiveScheduler: .global(qos: .userInteractive)
        )
        
        return composer.compose()
    }
}
