//
//  C2BSubscriptionView.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SearchBarComponent
import SwiftUI
import TextFieldComponent
import UIPrimitives

public struct C2BSubscriptionView<Footer: View, Search: View>: View {
    
    public typealias SearchView = (TextFieldState, @escaping (TextFieldAction) -> Void) -> Search
    
    private let state: C2BSubscriptionState
    private let event: (C2BSubscriptionEvent) -> Void
    private let footerView: () -> Footer
    private let searchView: SearchView
    
    public init(
        state: C2BSubscriptionState,
        event: @escaping (C2BSubscriptionEvent) -> Void,
        footerView: @escaping () -> Footer,
        searchView: @escaping SearchView
    ) {
        self.state = state
        self.event = event
        self.footerView = footerView
        self.searchView = searchView
    }
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            switch state.filteredList {
            case .none:
                emptyView()
                
            case let .some(filteredList):
                listView(filteredList)
            }
            
            footerView()
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
            
            searchView(state.textFieldState, { event(.textField($0)) })
                .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 32) {
                    
                    ForEach(list, content: productSubscriptionView)
                }
            }
        }
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
            .onTapGesture { event(.subscriptionTap(.init(
                subscription: subscription,
                event: .detail
            ))) }
            
            Button(action: { event(.subscriptionTap(.init(
                subscription: subscription,
                event: .delete
            ))) }) {
                
                Image(systemName: "trash")
            }
        }
        .padding(.horizontal)
    }
}

private extension C2BSubscriptionState {
    
    var filteredList: [GetC2BSubResponse.Details.ProductSubscription]? {
        
        guard case let .list(list) = getC2BSubResponse.details
        else { return nil }
        
        return list.compactMap { $0.filtered(searchText: searchTest) }
    }
    
    private var searchTest: String {
        
        switch textFieldState {
        case .placeholder:
            return ""
            
        case let .noFocus(text):
            return text
            
        case let .editing(textState):
            return textState.text
        }
    }
}

private extension GetC2BSubResponse.Details.ProductSubscription {
    
    func filtered(searchText: String) -> Self? {
        
        let filteredSubscriptions = subscriptions.filtered(
            with: searchText,
            keyPath: \.brandName
        )
        
        guard !filteredSubscriptions.isEmpty else { return nil }
        
        return .init(
            productID: productID,
            productType: productType,
            productTitle: productTitle,
            subscriptions: filteredSubscriptions
        )
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
}
