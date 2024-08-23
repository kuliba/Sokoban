//
//  PaymentsTransfersToolbarContentView.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import PayHub
import SwiftUI

public struct PaymentsTransfersToolbarContentView<ProfileLabel, QRLabel>: View
where ProfileLabel: View,
      QRLabel: View {
    
    private let state: State
    private let event: (Event) -> Void
    private let factory: Factory
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.event = event
        self.factory = factory
    }
    
    public var body: some View {
        
        Color.clear
            .frame(height: 1)
            .toolbar(content: toolbar)
    }
}

public extension PaymentsTransfersToolbarContentView {
    
    typealias State = PaymentsTransfersToolbarState
    typealias Event = PaymentsTransfersToolbarEvent
    typealias Factory = PaymentsTransfersToolbarContentViewFactory<ProfileLabel, QRLabel>
}

struct PaymentsTransfersToolbarContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        preview(.init())
    }
    
    private static func preview(
        _ state: PaymentsTransfersToolbarContentView.State
    ) -> some View {
        
        NavigationView {
            
            PaymentsTransfersToolbarContentView(
                state: state,
                event: { print($0) },
                factory: .init(
                    makeProfileLabel: {
                        
                        if #available(iOS 14.5, *) {
                            Label("Profile", systemImage: "person.circle")
                                .labelStyle(.titleAndIcon)
                        } else {
                            HStack {
                                Image(systemName: "person.circle")
                                Text("Profile")
                            }
                        }
                    },
                    makeQRLabel: {
                        Image(systemName: "qrcode")
                    }
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private extension PaymentsTransfersToolbarContentView {
    
    @ToolbarContentBuilder
    func toolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .topBarLeading) {
            
            Button {
                event(.select(.profile))
            } label: {
                factory.makeProfileLabel()
            }
            .buttonStyle(.plain)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            
            Button {
                event(.select(.qr))
            } label: {
                factory.makeQRLabel()
            }
            .buttonStyle(.plain)
        }
    }
}
