//
//  ProductsLandingView.swift
//
//
//  Created by Дмитрий Савушкин on 11.03.2025.
//

import SwiftUI
import UIPrimitives

struct ProductsLandingView: View {
    
    let imageFactory: ImageViewFactory
    let products: [Product]
    let config: ProductLandingConfig
    
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
            
            imageFactory.makeBannerImageView(product.imageURL)
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
        
        Button(action: {
            //TODO: implement action
        }) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: config.orderButtonConfig.cornerRadius)
                    .foregroundColor(config.orderButtonConfig.background)
                
                config.orderButtonConfig.title.render()
            }
        }
    }
    
    func conditionButton() -> some View {
        
        Button(action: {
            //TODO: implement action
        }) {
            
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
            
            Spacer()
        }
    }
}

extension ProductLandingConfig.ItemConfig {
    
    var circleSize: CGSize { .init(width: circle, height: circle) }
}

extension ProductLandingConfig {
    
    static let preview: Self = .init(
        background: .gray,
        buttonsConfig: .init(
            buttonsPadding: 16,
            buttonsSpacing: 44,
            buttonsHeight: 56
        ),
        conditionButtonConfig: .init(
            icon: .bolt,
            spacing: 12,
            frame: 20,
            title: .init(
                text: "Подробные уcловия",
                config: .init(
                    textFont: .body,
                    textColor: .black
                )
            )
        ),
        item: .init(
            circle: 5,
            title: .init(
                textFont: .body,
                textColor: .black
            ),
            itemPadding: 16
        ),
        imageCoverConfig: .init(
            height: 236,
            cornerRadius: 12,
            horizontalPadding: 16,
            verticalPadding: 12
        ),
        orderButtonConfig: .init(
            background: .red,
            cornerRadius: 8,
            title: .init(
                text: "Заказать",
                config: .init(
                    textFont: .body,
                    textColor: .white
                )
            )
        ),
        title: .init(
            textFont: .largeTitle,
            textColor: .black
        )
    )
}

extension Product {
    
    static let product: Self = .init(
        title: "Карта МИР «Все включено»",
        items: [
            .init(
                bullet: true,
                title: "0 ₽. Условия обслуживания Кешбэк до 10 000 ₽ в месяц"
            ),
            .init(
                bullet: true,
                title: "5% выгода при покупке топлива"
            ),
            .init(
                bullet: true,
                title: "5% на категории сезона"
            ),
            .init(
                bullet: true,
                title: "от 0,5% до 1% кешбэк на остальные покупки**"
            ),
            .init(
                bullet: true,
                title: "8% годовых при сумме остатка от 500 001 ₽ на карте"
            )
        ],
        imageURL: "1",
        terms: .init(fileURLWithPath: ""),
        action: .init(
            type: "",
            target: "",
            fallbackURL: .init(fileURLWithPath: "")
        )
    )
}

#Preview {
    
    Group {
        
        ProductsLandingView(
            imageFactory: .default,
            products: [.product],
            config: .preview
        )
    }
}
