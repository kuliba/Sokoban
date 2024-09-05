//
//  ComposedPaymentsTransfersPersonalToolbarView.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Foundation
import PayHub
import SwiftUI

public struct ComposedPaymentsTransfersPersonalToolbarView<DestinationView, FullScreenView, Profile, ProfileLabel, QR, QRLabel>: View
where DestinationView: View,
      FullScreenView: View,
      ProfileLabel: View,
      QRLabel: View {
    
    private let binder: Binder
    private let factory: Factory
    
    public init(
        binder: Binder,
        factory: Factory
    ) {
        self.binder = binder
        self.factory = factory
    }
    
    public var body: some View {
        
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

public extension ComposedPaymentsTransfersPersonalToolbarView {
    
    typealias Binder = PaymentsTransfersPersonalToolbarBinder<Profile, QR>
    typealias Factory = ComposedPaymentsTransfersToolbarViewFactory<DestinationView, FullScreenView, Profile, ProfileLabel, QR, QRLabel>
}

private extension ComposedPaymentsTransfersPersonalToolbarView {
    
    func makeContent(
        _ content: PaymentsTransfersPersonalToolbarContent
    ) -> some View {
        
        PaymentsTransfersPersonalToolbarContentWrapperView(
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
