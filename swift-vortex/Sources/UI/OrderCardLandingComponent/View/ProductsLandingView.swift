//
//  ProductsLandingView.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import SwiftUI
import UIPrimitives

public struct ProductsLandingView<ProductView: View>: View {
    
    private let products: [Product]
    private let productView: (Product) -> ProductView
    
    public init(
        products: [Product],
        productView: @escaping (Product) -> ProductView
    ) {
        self.products = products
        self.productView = productView
    }
    
    public var body: some View {
        
        ForEach(products, id: \.title, content: productView)
    }
}

public extension ProductsLandingView 
where ProductView == OrderCardLandingComponent.ProductView {
    
    init(
        products: [Product],
        event: @escaping (ProductLandingEvent) -> Void,
        config: ProductLandingConfig,
        viewFactory: ImageViewFactory
    ) {
        self.init(
            products: products,
            productView: {
            
                ProductView(
                    product: $0,
                    event: event,
                    config: config,
                    viewFactory: viewFactory
                )
            }
        )
    }
}

public struct ProductView: View {
    
    let product: Product
    let event: (ProductLandingEvent) -> Void
    let config: ProductLandingConfig
    let viewFactory: ImageViewFactory
    
    public var body: some View {
        
        VStack {
            
            product.title.text(
                withConfig: product.theme == .dark ? config.titleLight : config.titleDark
            )
            
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
    }
    
    func buttonsView() -> some View {
        
        HStack(spacing: config.buttonsConfig.buttonsSpacing) {
            
            conditionButton(config: config.conditionButtonConfig)
            
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
    
    @ViewBuilder
    func conditionButton(
        config: ProductLandingConfig.ConditionButtonConfig
    ) -> some View {
        
        if let url = URL(string: product.terms) {
            
            Button(action: { event(.info(url)) }) {
                
                HStack(spacing: config.spacing) {
                    
                    config.icon
                        .frame(width: config.frame, height: config.frame)
                        .foregroundStyle(product.theme == .dark ? config.foregroundColorLight : config.foregroundColorDark)
                    
                    config.title.text(
                        withConfig: product.theme == .dark ? config.titleDark : config.titleLight
                    )
                }
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
