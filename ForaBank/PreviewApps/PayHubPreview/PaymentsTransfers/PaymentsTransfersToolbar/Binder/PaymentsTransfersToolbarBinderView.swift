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

struct PaymentsTransfersToolbarBinderView: View {

    let binder: PaymentsTransfersToolbarBinder
    
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

extension PaymentsTransfersToolbarBinderView {
    
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
