//
//  SwiftUIView.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import SwiftUI
import SharedConfigs

struct ProductView<IconView>: View
where IconView: View {
    
    let product: Product
    let isLoading: Bool
    let config: ProductConfig
    let makeIconView: (String) -> IconView
    
    var body: some View {
        
        productView(
            designMd5hash: product.image,
            header: product.header,
            orderOption: product.orderOption,
            needShimmering: isLoading
        )
    }
    
    private func productView(
        designMd5hash: String,
        header: (title: String, subtitle: String),
        orderOption: (open: String, service: String),
        needShimmering: Bool = false
    ) -> some View {
        
        VStack(spacing: 20) {
            
            productHeaderView(
                title: header.title,
                subtitle: header.subtitle,
                needShimmering: needShimmering
            )
            
            HStack(alignment: .top, spacing: config.padding) {
                
                makeIconView(designMd5hash)
                    .frame(width: 112, height: 72)
                
                productOptionsView(
                    open: orderOption.open,
                    service: orderOption.service,
                    needShimmering: needShimmering
                )
            }
        }
    }
    
    private func productHeaderView(
        title: String,
        subtitle: String,
        needShimmering: Bool = false
    ) -> some View {
        
        VStack(spacing: 4) {
            
            title.text(withConfig: config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 24)
            
            subtitle.text(withConfig: config.subtitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 16)
        }
    }
    
    private func productOptionView(
        title: String,
        subtitle: String,
        _ needShimmering: Bool
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            title.text(withConfig: config.optionTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(ShimmeringModifier(isLoading, config.shimmeringColor))
            
            HStack {
                
                if needShimmering {
                    
                    Circle()
                        .fill(config.shimmeringColor)
                        .frame(width: 16, height: 16, alignment: .center)
                        .shimmering()
                    
                } else {
                    
                    config.orderOptionIcon
                        .frame(width: 16, height: 16, alignment: .center)
                        .foregroundStyle(.green)
                }
                
                subtitle.text(withConfig: config.optionSubtitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShimmeringModifier(needShimmering, config.shimmeringColor))
            }
        }
    }
    
    private func productOptionsView(
        open: String,
        service: String,
        needShimmering: Bool = false
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            productOptionView(
                title: config.openOptionTitle,
                subtitle: open,
                needShimmering
            )
            
            productOptionView(
                title: config.serviceOptionTitle,
                subtitle: service,
                needShimmering
            )
        }
    }
}

struct ProductView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            productView(false)
            productView(true)
        }
    }
    
    private static func productView(
        _ isLoading: Bool
    ) -> some View {
        
        ProductView(
            product: .init(
                image: "",
                header: ("Все включено", "Кешбэк до 10 000 ₽ в месяц"),
                orderOption: (open: "Бесплатно", service: "0 ₽")
            ),
            isLoading: isLoading,
            config: .init(
                padding: 20,
                title: .init(textFont: .system(size: 18), textColor: .black),
                subtitle: .init(textFont: .system(size: 14), textColor: .black),
                optionTitle: .init(textFont: .system(size: 12), textColor: .gray),
                optionSubtitle: .init(textFont: .system(size: 16), textColor: .black),
                shimmeringColor: .gray,
                orderOptionIcon: .bolt,
                cornerRadius: 12,
                background: .red.opacity(0.2)
            ),
            makeIconView: { _ in EmptyView() }
        )
    }
}
