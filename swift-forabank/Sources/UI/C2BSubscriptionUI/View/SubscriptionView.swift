//
//  SubscriptionView.swift
//
//
//  Created by Igor Malyarov on 11.02.2024.
//

import SwiftUI

struct SubscriptionView: View {
    
    typealias Subscription = GetC2BSubResponse.Details.ProductSubscription.Subscription
    
    let subscription: Subscription
    let event: (C2BSubscriptionEvent.SubscriptionTap) -> Void
    
    var body: some View {
        
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
            .onTapGesture { event(.init(
                subscription: subscription,
                event: .detail
            )) }
            
            Button(action: { event(.init(
                subscription: subscription,
                event: .delete
            )) }) {
                
                Image(systemName: "trash")
            }
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        SubscriptionView(
            subscription: .preview,
            event: { _ in }
        )
    }
}
