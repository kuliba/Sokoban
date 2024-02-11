//
//  C2BSubscriptionView_Demo.swift
//  
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SwiftUI
import TextFieldComponent

public struct C2BSubscriptionView_Demo: View {
    
    @State var state: C2BSubscriptionState
    
    public init(state: C2BSubscriptionState) {
        
        self._state = .init(initialValue: state)
    }
    
    private let textFieldReducer = TransformingReducer(placeholderText: "Search")
    
    private func event(
        _ event: C2BSubscriptionEvent
    ) {
        switch event {
        case let .alertTap(alertEvent):
            switch alertEvent {
            case .cancel:
                state.status = nil
                
            case let .delete(subscription):
                // effect!!
                state.status = .inflight
                print("Effect: Delete subscription \(subscription.brandName)")
            }
            
        case let .subscriptionTap(tap):
            switch tap.event {
            case .delete:
                state.status = .tapAlert(.init(
                    title: tap.subscription.cancelAlert,
                    message: nil,
                    primaryButton: .init(
                        type: .default,
                        title: "Отключить",
                        event: .delete(tap.subscription)
                    ),
                    secondaryButton: .init(
                        type: .cancel,
                        title: "Отмена",
                        event: .cancel
                    )
                ))
                
            case .detail:
                state.status = .inflight
                // effect!!
                print("Effect: Request details for subscription \(tap.subscription.brandName)")
            }
            
        case let .textField(textFieldAction):
            guard let textFieldState = try? textFieldReducer.reduce(state.textFieldState, with: textFieldAction)
            else { return }
            
            state.textFieldState = textFieldState
        }
    }
    
    public var body: some View {
        
        NavigationView {
            
            C2BSubscriptionView(
                state: state,
                event: event,
                footer: {
                    Text("some footer with icon")
                        .foregroundColor(.secondary)
                },
                textFieldConfig: .preview
            )
            .navigationTitle(state.getC2BSubResponse.title)
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                item: .init(
                    get: { state.tapAlert },
                    set: { if $0 == nil { event(.alertTap(.cancel)) }}
                ),
                content: { .init(with: $0, event: { event(.alertTap($0))}) }
            )
        }
    }
}

private extension C2BSubscriptionState {
    
    var tapAlert: TapAlert? {
        
        guard case let .tapAlert(tapAlert) = status
        else { return nil }
        
        return tapAlert
    }
}

struct C2BSubscriptionView_Demo_Previews: PreviewProvider {
    
    static var previews: some View {
        
        C2BSubscriptionView_Demo(state: .control)
        C2BSubscriptionView_Demo(state: .empty)
    }
}
