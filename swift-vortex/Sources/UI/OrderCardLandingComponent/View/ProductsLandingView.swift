//
//  ProductsLandingView.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import SwiftUI
import UIPrimitives

struct ProductsLandingView: View {
    
    typealias Event = ProductLandingEvent
    
    let event: (Event) -> Void
    let products: [Product]
    let config: ProductLandingConfig
    let viewFactory: ImageViewFactory
    
    var body: some View {
        
        ForEach(products, id: \.title, content: productView)
    }
    
    func productView(
        product: Product
    ) -> some View {
        
        VStack {
            
            product.title.text(withConfig: config.title)
            
            ForEach(product.items, id: \.title, content: itemView)
                .padding(.horizontal, config.item.itemPadding)
            
            viewFactory.makeBannerImageView(product.imageURL)
                .frame(height: config.imageCoverConfig.height)
                .cornerRadius(config.imageCoverConfig.cornerRadius)
                .padding(.horizontal, config.imageCoverConfig.horizontalPadding)
                .padding(.vertical, config.imageCoverConfig.verticalPadding)
            
            buttonsView()
                .padding(.horizontal, config.buttonsConfig.buttonsPadding)
        }
        .background()
    }
    
    func buttonsView(
    ) -> some View {
        
        HStack(spacing: config.buttonsConfig.buttonsSpacing) {
            
            conditionButton()
            
            orderButton()
        }
        .frame(height: config.buttonsConfig.buttonsHeight)
    }
    
    func orderButton() -> some View {
        
        Button(action: { event(.order) }) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: config.orderButtonConfig.cornerRadius)
                    .foregroundColor(config.orderButtonConfig.background)
                
                config.orderButtonConfig.title.render()
            }
        }
    }
    
    func conditionButton() -> some View {
        
        Button(action: { event(.info) }) {
            
            HStack(spacing: config.conditionButtonConfig.spacing) {
                
                config.conditionButtonConfig.icon
                    .frame(
                        width: config.conditionButtonConfig.frame,
                        height: config.conditionButtonConfig.frame,
                        alignment: .center
                    )
                
                config.conditionButtonConfig.title.render()
            }
        }
    }
    
    func itemView(
        item: Product.Item
    ) -> some View {
        
        HStack {
            
            if item.bullet {
                
                Circle()
                    .frame(config.item.circleSize)
            }
            
            item.title.text(withConfig: config.item.title)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension ProductLandingConfig.ItemConfig {
    
    var circleSize: CGSize { .init(width: circle, height: circle) }
}

#Preview {
    
    Group {
        
        ProductsLandingView(
            event: { event in },
            products: [.product],
            config: .preview,
            viewFactory: .default
        )
    }
}
