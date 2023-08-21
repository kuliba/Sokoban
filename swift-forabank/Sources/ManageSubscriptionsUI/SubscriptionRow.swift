//
//  SubscriptionRow.swift
//  
//
//  Created by Дмитрий Савушкин on 19.07.2023.
//

import SwiftUI

struct SubscriptionRow<P: Product, ProductView: View>: View {
    
    let product: P
    let productView: (P) -> ProductView
    
    var body: some View {
        
        VStack {
            
            productView(product)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.3))
                .opacity(0.3)
            
            ForEach(product.subscriptions) { subscription in
                
                SubscriptionView(viewModel: subscription)
                
                if product.subscriptions.last?.id != subscription.id {
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                        .opacity(0.3)
                }
            }
        }
    }
}
