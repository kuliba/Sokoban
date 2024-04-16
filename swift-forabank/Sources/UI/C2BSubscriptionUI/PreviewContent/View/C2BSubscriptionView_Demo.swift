//
//  C2BSubscriptionView_Demo.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SwiftUI
import TextFieldComponent
import UIPrimitives

public struct C2BSubscriptionView_Demo: View {
    
    @State var state: C2BSubscriptionState
    
    public init(state: C2BSubscriptionState) {
        
        self._state = .init(initialValue: state)
    }
    
    private let c2bSubscriptionReducer = C2BSubscriptionReducer()
    private let c2bSubscriptionEffectHandler: C2BSubscriptionEffectHandler = .preview
    
    private func event(
        _ event: C2BSubscriptionEvent
    ) {
        let (state, effect) = c2bSubscriptionReducer.reduce(state, event)
        self.state = state
        
        if let effect {
            
            switch effect {
            case let .subscription(subscriptionEffect):
                c2bSubscriptionEffectHandler.handleEffect(subscriptionEffect) {
                    
                    self.event(.subscription($0))
                }
            }
        }
    }
    
    public var body: some View {
        
        ZStack {
            
            NavigationView {
                
                c2bSubscriptionView()
            }
            
            if state.status == .inflight {
                
                Color.gray
                    .opacity(0.7)
                    .ignoresSafeArea()
                
                ProgressView()
            }
        }
    }
    
    private func c2bSubscriptionView() -> some View {
        
        C2BSubscriptionView(
            state: state,
            event: event,
            footerView: {
                Text("some footer with icon")
                    .foregroundColor(.secondary)
            },
            searchView: {
                
                SearchView(
                    textFieldState: $0,
                    event: $1,
                    textFieldConfig: .preview
                )
            },
            config: .preview
        )
        .navigationTitle(state.getC2BSubResponse.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct C2BSubscriptionView_Demo_Previews: PreviewProvider {
    
    static var previews: some View {
        
        C2BSubscriptionView_Demo(state: .control)
        C2BSubscriptionView_Demo(state: .empty)
    }
}
