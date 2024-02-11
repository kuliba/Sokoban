//
//  C2BSubscriptionView.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SearchBarComponent
import SwiftUI
import TextFieldUI

struct C2BSubscriptionView<Footer: View>: View {
    
    let state: C2BSubscriptionState
    let event: (String) -> Void
    let footer: () -> Footer
    let textFieldConfig: TextFieldView.TextFieldConfig
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            switch state.getC2BSubResponse.details {
            case .empty:
                emptyView()
                
            case let .list(list):
                listView(list)
            }
            
            footer()
        }
    }
    
    private func emptyView() -> some View {
        
        Text("TBD: Empty view")
            .foregroundColor(.red)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func listView(
        _ list: [GetC2BSubResponse.Details.ProductSubscription]
    ) -> some View {
        
        VStack(spacing: 24) {
            
            searchView()
            Text("TBD: Listview").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    #warning("looks like `searchTest` in state in not enough, need `TextFieldState` otherwise correct mapping is impossible")
    private func searchView() -> some View {
        
        CancellableSearchView(
            state: .editing(.init(state.searchTest)),
            send: {
                switch $0 {
                case .startEditing:
                    break
                case .finishEditing:
                    break
                case .changeText:
                    break
                case let .setTextTo(text):
                    text.map(event)
                }
            },
            clearButtonLabel: PreviewClearButton.init,
            cancelButton: PreviewCancelButton.init,
            keyboardType: .default,
            toolbar: nil,
            textFieldConfig: textFieldConfig
        )
        .padding(.horizontal)
    }
}

struct C2BSubscriptionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        C2BSubscriptionView_Demo(state: .control)
        C2BSubscriptionView_Demo(state: .empty)
    }
    
    struct C2BSubscriptionView_Demo: View {
        
        @State var state: C2BSubscriptionState
        
        var body: some View {
            
            NavigationView {
                
                C2BSubscriptionView(
                    state: state,
                    event: { $state.wrappedValue.searchTest = $0 },
                    footer: {
                        Text("some footer with icon")
                            .foregroundColor(.secondary)
                    },
                    textFieldConfig: .preview
                )
                .navigationTitle(state.getC2BSubResponse.title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

extension C2BSubscriptionState {
    
    static let control: Self = .init(getC2BSubResponse: .control)
    static let empty: Self = .init(getC2BSubResponse: .empty)
}
