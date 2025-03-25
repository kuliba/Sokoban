//
//  ProductCardView.swift
//
//
//  Created by Igor Malyarov on 25.03.2025.
//

import SwiftUI
import UIPrimitives

struct ProductCardView<IconView: View>: View {
    
    let product: ProductCard
    let config: Config
    let iconView: (String) -> IconView
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: config.spacing) {
            
            header(config: config.header)
            label(config: config.label)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(config.edges)
        .background(config.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
    }
}

private extension ProductCardView {
    
    func header(config: Config.HeaderConfig) -> some View {
        
        VStack(alignment: .leading, spacing: config.spacing) {
            
            product.title.text(withConfig: config.title)
            product.subtitle.text(withConfig: config.subtitle)
        }
    }
    
    func label(config: Config.LabelConfig) -> some View {
        
        HStack(alignment: .top, spacing: config.spacing) {
            
            icon()
            title(config: config.title)
        }
    }
    
    func icon() -> some View {
        
        iconView(product.md5Hash)
            .frame(config.label.icon.size)
            .clipShape(RoundedRectangle(cornerRadius: config.label.icon.cornerRadius))
            .background(alignment: .bottom, content: shadow)
            .frame(height: iconFrameHeight, alignment: .top)
    }
    
    private var iconFrameHeight: CGFloat {
        
        config.label.icon.size.height + shadowConfig.offset + shadowConfig.blur
    }
    
    func shadow() -> some View {
        
        shadowConfig.color
            .frame(shadowConfig.size)
            .offset(y: shadowConfig.offset)
            .blur(radius: shadowConfig.blur)
    }
    
    private var shadowConfig: Config.LabelConfig.IconConfig.ShadowConfig {
        
        config.label.icon.shadow
    }
    
    func title(config: Config.LabelConfig.TitleConfig) -> some View {
        
        VStack(alignment: .leading, spacing: config.spacing) {
            
            ForEach(product.options, id: \.title, content: optionView)
        }
    }
    
    func optionView(
        option: ProductCard.Option
    ) -> some View {
        
        VStack(alignment: .leading, spacing: optionConfig.spacing) {
            
            option.title.text(withConfig: optionConfig.title)
            optionLabel(option)
        }
    }
    
    func optionLabel(
        _ option: ProductCard.Option
    ) -> some View {
        
        HStack(spacing: optionConfig.valueSpacing) {
            
            optionConfig.icon
                .resizable()
                .foregroundColor(optionConfig.iconColor)
                .frame(iconSize)
            
            option.value.text(withConfig: optionConfig.value)
        }
    }
    
    var iconSize: CGSize {
        
        return .init(width: optionConfig.iconSize, height: optionConfig.iconSize)
    }
    
    private var optionConfig: Config.LabelConfig.OptionConfig { config.label.option }
}

extension ProductCardView {
    
    typealias Config = ProductCardViewConfig
}

// MARK: - Previews

struct ProductCardView_Previews:  PreviewProvider {
    
    static var previews: some View {
        
        productCardView()
    }
    
    private static func productCardView() -> some View {
        
        ProductCardView(product: .preview(), config: .preview()) { _ in
            
            Color.red
        }
        .padding()
    }
}
