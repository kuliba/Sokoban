//
//  PaymentsTransfersToolbarBinderView.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Foundation
import PayHub
import PayHubUI
import SwiftUI

struct ComposedPaymentsTransfersToolbarView<DestinationView, FullScreenView, ProfileLabel, QRLabel>: View
where DestinationView: View,
      FullScreenView: View,
      ProfileLabel: View,
      QRLabel: View {
    
    let binder: PaymentsTransfersToolbarBinder
    let factory: Factory
    
    var body: some View {
        
        PaymentsTransfersToolbarFlowWrapperView(
            model: binder.flow
        ) {
            PaymentsTransfersToolbarFlowView(
                state: $0,
                event: $1,
                factory: .init(
                    makeContent: { self.makeContent(binder.content) },
                    makeDestination: factory.makeDestinationView,
                    makeFullScreen: factory.makeFullScreenView
                )
            )
        }
    }
}

extension ComposedPaymentsTransfersToolbarView {
    
    typealias Factory = ComposedPaymentsTransfersToolbarViewFactory<DestinationView, FullScreenView, ProfileLabel, QRLabel>
}

extension ComposedPaymentsTransfersToolbarView {
    
    func makeContent(
        _ content: PaymentsTransfersToolbarContent
    ) -> some View {
        
        PaymentsTransfersToolbarContentWrapperView(
            model: content,
            makeContentView: {
                
                PaymentsTransfersToolbarContentView(
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
