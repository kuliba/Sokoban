//
//  ProductsLandingView.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import SwiftUI
import UIPrimitives

public struct ProductsLandingView: View {
    
    let products: [Product]
    let event: (ProductLandingEvent) -> Void
    let config: ProductLandingConfig
    let viewFactory: ImageViewFactory
    
    public init(
        products: [Product],
        event: @escaping (ProductLandingEvent) -> Void,
        config: ProductLandingConfig,
        viewFactory: ImageViewFactory
    ) {
        self.products = products
        self.event = event
        self.config = config
        self.viewFactory = viewFactory
    }
    
    public var body: some View {
        
        ForEach(products, id: \.title, content: productView)
    }
    
    func productView(
        product: Product
    ) -> some View {
        
       return VStack {
            
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
        .background(product.backgroundColor)
        
        func buttonsView() -> some View {
            
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
                        .foregroundStyle(product.theme == .dark ? config.conditionButtonConfig.foregroundColorLight : config.conditionButtonConfig.foregroundColorDark)
                    
                    config.conditionButtonConfig.title.text(
                        withConfig: product.theme == .dark ? config.conditionButtonConfig.titleDark : config.conditionButtonConfig.titleLight
                    )
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
                        .foregroundStyle(product.theme == .dark ? config.conditionButtonConfig.foregroundColorLight : config.conditionButtonConfig.foregroundColorDark)
                }
                
                item.title.text(
                    withConfig: product.theme == .dark ? config.item.titleDark : config.item.titleLight
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

extension ProductLandingConfig.ItemConfig {
    
    var circleSize: CGSize { .init(width: circle, height: circle) }
}

#Preview {
    
    Group {
        
        ProductsLandingView(
            products: [.product],
            event: { event in },
            config: .preview,
            viewFactory: .default
        )
    }
}
