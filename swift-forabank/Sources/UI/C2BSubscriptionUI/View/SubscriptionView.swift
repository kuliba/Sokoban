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
            
            label()
            icon()
        }
    }
    
    private func label() -> some View {
        
        HStack {
            
#warning("add icon fallback")
            subscription.brandIcon.image(withFallback: .init(systemName: "cart"))
                .resizable()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                
                Text(subscription.brandName)
                    .font(.headline)
                
                Text(subscription.purpose.rawValue)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture { self.event(.init(
            subscription: subscription,
            event: .detail
        )) }
    }
    
    private func icon() -> some View {
        
        Button(action: { self.event(.init(
            subscription: subscription,
            event: .delete
        )) }) {
            
            Image(systemName: "trash")
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
