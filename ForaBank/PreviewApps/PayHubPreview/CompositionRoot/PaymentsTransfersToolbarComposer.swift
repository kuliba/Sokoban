//
//  PaymentsTransfersToolbarComposer.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Foundation
import PayHub
import PayHubUI
import SwiftUI

final class PaymentsTransfersToolbarComposer<Profile, QR> {}

extension PaymentsTransfersToolbarComposer {
    
    func compose(
        binder: PaymentsTransfersToolbarBinder<Profile, QR>
    ) -> some View {
        
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

extension PaymentsTransfersToolbarComposer {
    
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
                        makeProfileLabel: self.makeProfileLabel,
                        makeQRLabel: self.makeQRLabel
                    )
                )
            }
        )
    }
    
    #warning("inject")
    private func makeProfileLabel() -> some View {
        
        HStack {
            Image(systemName: "person.circle")
            Text("Profile")
        }
    }
    
    #warning("inject")
    private func makeQRLabel() -> some View  {
        
        Image(systemName: "qrcode")
    }

    #warning("inject")
    @ViewBuilder
    private func makeDestination(
        destination: PaymentsTransfersToolbarFlowState<Profile, QR>.Destination
    ) -> some View {
        
        switch destination {
        case let .profile(profileModel):
            Text(String(describing: profileModel))
        }
    }
    
#warning("inject")
    @ViewBuilder
    private func makeFullScreen(
        fullScreen: PaymentsTransfersToolbarFlowState<Profile, QR>.FullScreen,
        event: @escaping (PaymentsTransfersToolbarFlowEvent<Profile, QR>) -> Void
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
