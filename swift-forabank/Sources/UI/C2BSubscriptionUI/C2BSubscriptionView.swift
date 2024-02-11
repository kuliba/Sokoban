//
//  C2BSubscriptionView.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SearchBarComponent
import SwiftUI
import TextFieldComponent

struct C2BSubscriptionView<Footer: View>: View {
    
    let state: C2BSubscriptionState
    let event: (TextFieldAction) -> Void
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
    
    private typealias ProductSubscription = GetC2BSubResponse.Details.ProductSubscription
    
    private func listView(
        _ list: [ProductSubscription]
    ) -> some View {
        
        VStack(spacing: 24) {
            
            searchView()
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    
                    ForEach(list, content: productSubscriptionView)
                }
            }
        }
    }

    private func searchView() -> some View {
        
        CancellableSearchView(
            state: state.textFieldState,
            send: event,
            clearButtonLabel: PreviewClearButton.init,
            cancelButton: PreviewCancelButton.init,
            keyboardType: .default,
            toolbar: nil,
            textFieldConfig: textFieldConfig
        )
        .padding(.horizontal)
    }
    
    private func productSubscriptionView(
        _ productSubscription: ProductSubscription
    ) -> some View {
        
        VStack {
            
            productView(productSubscription.productDetails)
            
            ForEach(productSubscription.subscriptions, content: subscriptionView)
        }
    }
    
    private func productView(
        _ productDetails: ProductSubscription.ProductDetails
    ) -> some View {
        
        Text("TBD: ProductDetails")
    }
    
    private func subscriptionView(
        _ subscription: ProductSubscription.Subscription
    ) -> some View {
        
        HStack {
            
            HStack {
                
#warning("add icon fallback")
                // Image(subscription.brandIcon)
                Image(systemName: "tortoise.circle")
                    .resizable()
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading) {
                    
                    Text(subscription.brandName)
                        .font(.headline)
                    
                    Text(subscription.subscriptionPurpose)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
            .onTapGesture { fatalError() }
            
            Button(action: { fatalError() }) {
                
                Image(systemName: "trash")
            }
        }
        .padding(.horizontal)
    }
}

extension GetC2BSubResponse.Details.ProductSubscription: Identifiable {
    
    public var id: String { productID }
}
 
private extension GetC2BSubResponse.Details.ProductSubscription {
    
    var productDetails: ProductDetails {
        
        .init(
            productID: productID,
            productType: productType,
            productTitle: productTitle
        )
    }
    
    struct ProductDetails {
        
        let productID: String
        let productType: ProductType
        let productTitle: String
    }
}

extension GetC2BSubResponse.Details.ProductSubscription.Subscription: Identifiable {
    
    public var id: String { subscriptionToken }
}

struct C2BSubscriptionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        C2BSubscriptionView_Demo(state: .control)
        C2BSubscriptionView_Demo(state: .empty)
    }
    
    struct C2BSubscriptionView_Demo: View {
        
        @State var state: C2BSubscriptionState
        
        private let reducer = TransformingReducer(placeholderText: "Search")
        
        private func event(
            _ textFieldAction: TextFieldAction
        ) {
            guard let textFieldState = try? reducer.reduce(state.textFieldState, with: textFieldAction)
            else { return }
            
            state.textFieldState = textFieldState
        }
        
        var body: some View {
            
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
            }
        }
    }
}

extension C2BSubscriptionState {
    
    static let control: Self = .init(getC2BSubResponse: .control)
    static let empty: Self = .init(getC2BSubResponse: .empty)
}
