//
//  Product.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import Foundation

struct Product {
    
    let designMd5hash: String?
    let header: Header
    let openValue: String
    let orderServiceOption: String
    
    struct Header {
        let title: String
        let subtitle: String
    }
}

import SwiftUI

struct ProductView<IconView>: View
where IconView: View {

    let data: Product
    let config: OrderSavingsAccountConfig
    let makeIconView: (String) -> IconView
    let isLoading: Bool
    
    var body: some View {
        order(
            designMd5hash: data.designMd5hash ?? "",
            header: (data.header.title, data.header.subtitle),
            orderOption: (
                data.openValue,
                data.orderServiceOption
            ),
            needShimmering: isLoading
        )
    }
    
    private func order(
        designMd5hash: String,
        header: (title: String, subtitle: String),
        orderOption: (open: String, service: String),
        needShimmering: Bool = false
    ) -> some View {
        
        VStack {
            
            orderHeader(title: header.title, subtitle: header.subtitle, needShimmering: needShimmering)
            
            HStack(alignment:.top, spacing: config.padding) {
                
                ZStack {
                    shadow()
                    product(designMd5hash: designMd5hash, needShimmering)
                    
                }
                orderOptions(
                    open: orderOption.open,
                    service: orderOption.service,
                    needShimmering: needShimmering
                )
            }
        }
        .modifier(ViewWithBackgroundCornerRadiusAndPaddingModifier(config.background, config.cornerRadius, 0))
    }

    private func shadow() -> some View {
        
        RoundedRectangle(cornerRadius: config.cornerRadius)
            .frame(width: config.frame.width, height: config.frame.height)
            .foregroundColor(config.shadowColor)
            .offset(x: 0, y: config.cornerRadius)
            .blur(radius: 8)
    }

    @ViewBuilder
    private func product(
        designMd5hash: String,
        _  needShimmering: Bool
    ) -> some View {
        
        if needShimmering {
            RoundedRectangle(cornerRadius: 8)
                .fill(config.shimmering)
                .frame(config.order.card)
                .shimmering()
        }
        else {
            makeIconView(designMd5hash)
                .aspectRatio(contentMode: .fit)
                .frame(config.order.card)
        }
    }

    private func orderHeader(
        title: String,
        subtitle: String,
        needShimmering: Bool = false
    ) -> some View {
        
        VStack(spacing: 0) {
            
            title.text(withConfig: config.order.header.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 24)
                .modifier(ShimmeringModifier(needShimmering, config.shimmering))
            
            subtitle.text(withConfig: config.order.header.subtitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 16)
                .modifier(ShimmeringModifier(needShimmering, config.shimmering))
        }
    }
    
    private func orderOption(
        title: String,
        subtitle: String,
        _ needShimmering: Bool
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            title.text(withConfig: config.order.options.config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .modifier(ShimmeringModifier(needShimmering, config.shimmering))
            
            HStack {
                if needShimmering {
                    Circle()
                        .fill(config.shimmering)
                        .frame(config.order.imageSize)
                        .shimmering()
                } else {
                    config.order.image
                        .renderingMode(.template)
                        .foregroundColor(.green)
                        .frame(config.order.imageSize)
                }
                subtitle.text(withConfig: config.order.options.config.subtitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ShimmeringModifier(needShimmering, config.shimmering))
            }
        }
    }
    
    private func orderOptions(
        open: String,
        service: String,
        needShimmering: Bool = false
    ) -> some View {
        
        VStack(alignment: .leading) {
            
            orderOption(
                title: config.order.options.headlines.open.string(needShimmering),
                subtitle: open,
                needShimmering
            )
            
            orderOption(title: config.order.options.headlines.service.string(needShimmering),
                        subtitle: service,
                        needShimmering
            )
        }
    }
}

private extension OrderSavingsAccountConfig {
    
    var frame: CGSize {
        
        .init(
            width: order.card.width - cornerRadius * 2,
            height: order.card.height
        )
    }
}
