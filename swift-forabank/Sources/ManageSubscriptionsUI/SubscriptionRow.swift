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
            
            ForEach(product.subscriptions, content: SubscriptionView.init(viewModel:))
        }
    }
}
