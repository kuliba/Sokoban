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

struct ComposedPaymentsTransfersToolbarView<ProfileLabel, QRLabel>: View
where ProfileLabel: View,
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
                    makeDestination: self.makeDestination,
                    makeFullScreen: {
                        
                        self.makeFullScreen(
                            fullScreen: $0,
                            event: binder.flow.event
                        )
                    }
                )
            )
        }
    }
}

extension ComposedPaymentsTransfersToolbarView {
    
    typealias Factory = ComposedPaymentsTransfersToolbarViewFactory<ProfileLabel, QRLabel>
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
    
#warning("inject")
    @ViewBuilder
    private func makeDestination(
        destination: PaymentsTransfersToolbarFlowState<ProfileModel, QRModel>.Destination
    ) -> some View {
        
        switch destination {
        case let .profile(profileModel):
            Text(String(describing: profileModel))
        }
    }
    
#warning("inject")
    @ViewBuilder
    private func makeFullScreen(
        fullScreen: PaymentsTransfersToolbarFlowState<ProfileModel, QRModel>.FullScreen,
        event: @escaping (PaymentsTransfersToolbarFlowEvent<ProfileModel, QRModel>) -> Void
    ) -> some View {
        
        switch fullScreen {
        case let .qr(qrModel):
            VStack(spacing: 32) {
                
                Text(String(describing: qrModel))
                Button("Close") { event(.dismiss) }
            }
        }
    }
}
