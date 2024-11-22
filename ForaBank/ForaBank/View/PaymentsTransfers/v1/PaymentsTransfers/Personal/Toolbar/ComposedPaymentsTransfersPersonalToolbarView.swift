//
//  ComposedPaymentsTransfersPersonalToolbarView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.11.2024.
//

import PayHubUI
import RxViewModel
import SwiftUI

struct ComposedPaymentsTransfersPersonalToolbarView<DestinationView, FullScreenView, ProfileLabel, QRLabel>: View
where DestinationView: View,
      FullScreenView: View,
      ProfileLabel: View,
      QRLabel: View {
    
    let binder: Binder
    let factory: Factory
    
    var body: some View {
        
        RxWrapperView(
            model: binder.flow,
            makeContentView: {
                
                PaymentsTransfersPersonalToolbarFlowView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeContent: { makeContent(binder.content) },
                        makeDestination: factory.makeDestinationView,
                        makeFullScreen: factory.makeFullScreenView
                    )
                )
            }
        )
    }
}

extension ComposedPaymentsTransfersPersonalToolbarView {
    
    typealias Domain = PaymentsTransfersPersonalToolbarDomain
    typealias Binder = Domain.Binder
    typealias Factory = ComposedPaymentsTransfersPersonalToolbarViewFactory<DestinationView, FullScreenView, ProfileLabel, QRLabel>
}

private extension ComposedPaymentsTransfersPersonalToolbarView {
    
    func makeContent(
        _ content: Domain.Content
    ) -> some View {
        
        RxWrapperView(
            model: content,
            makeContentView: {
                
                PaymentsTransfersPersonalToolbarContentView(
                    state: $0,
                    event: $1,
                    factory: .init(
                        makeProfileLabel: factory.makeProfileLabel,
                        makeQRLabel: factory.makeQRLabel
                    )
                )
            }
        )
    }
}
