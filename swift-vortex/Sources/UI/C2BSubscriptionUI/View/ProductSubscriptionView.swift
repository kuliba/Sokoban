//
//  ProductSubscriptionView.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SwiftUI

struct ProductSubscriptionView: View {
    
    typealias ProductSubscription = GetC2BSubResponse.Details.ProductSubscription
    
    let productSubscription: ProductSubscription
    let event: (C2BSubscriptionEvent.SubscriptionTap) -> Void
    let config: ProductConfig
    
    var body: some View {
        
        VStack {
            
            ProductView(
                product: productSubscription.product,
                config: config
            )
            
            Divider()
            
            ForEach(productSubscription.subscriptions) {
                
                subscriptionView(
                    $0,
                    isLast: isLast($0, in: productSubscription))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func subscriptionView(
        _ subscription: ProductSubscription.Subscription,
        isLast: Bool
    ) -> some View {
        
        SubscriptionView(
            subscription: subscription,
            event: { event($0) }
        )
        
        if !isLast { Divider() }
    }
    
    private func isLast(
        _ subscription: ProductSubscription.Subscription,
        in productSubscription: ProductSubscription
    ) -> Bool {
        
        productSubscription.subscriptions.last?.token == subscription.token
    }
}

struct ProductSubscriptionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ProductSubscriptionView(
            productSubscription: .init(
                product: .preview,
                subscriptions: [.preview]
            ),
            event: { _ in },
            config: .preview
        )
    }
}
