//
//  ProductCardView.swift
//
//
//  Created by Igor Malyarov on 25.03.2025.
//

import SwiftUI
import UIPrimitives

// TODO: extract to components library

struct ProductCard: Equatable {
    
    let md5Hash: String
    let options: [Option]
    let title: String
    let subtitle: String
}

extension ProductCard {
    
    struct Option: Equatable {
        
        let title: String
        let value: String
    }
}

// TODO: extract to PreviewContent

extension ProductCardViewConfig {
    
    static func preview() -> Self {
        
        return .init(
            backgroundColor: .gray.opacity(0.1), // main colors/ gray lightest
            cornerRadius: 12,
            edges: .init(top: 13, leading: 16, bottom: 13, trailing: 16),
            spacing: 20,
            header: .preview(),
            label: .preview()
        )
    }
}

extension ProductCardViewConfig.HeaderConfig {
    
    static func preview() -> Self {
        
        return .init(
            title: .init(
                textFont: .title3.bold(), // Text/H3/SB_18×24_0%
                textColor: .primary // Main colors/Black
            ),
            subtitle: .init(
                textFont: .subheadline, // Text/Body S/R_12×16_0%
                textColor: .secondary // placeholder (?)
            ),
            spacing: 4
        )
    }
}

extension ProductCardViewConfig.LabelConfig {
    
    static func preview() -> Self {
        
        return .init(
            icon: .preview(),
            option: .preview(),
            title: .init(spacing: 12),
            spacing: 20
        )
    }
}

extension ProductCardViewConfig.LabelConfig.IconConfig {
    
    static func preview() -> Self {
        
        return .init(
            cornerRadius: 8,
            shadow: .preview(),
            size: .init(width: 112, height: 72)
        )
    }
}

extension ProductCardViewConfig.LabelConfig.IconConfig.ShadowConfig {
    
    static func preview() -> Self {
        
        return .init(
            color: .secondary, // ???
            offset: 8,
            blur: 12,
            size: .init(width: 88, height: 54)
        )
    }
}

extension ProductCardViewConfig.LabelConfig.OptionConfig {
    
    static func preview() -> Self {
        
        return .init(
            icon: .init(systemName: "star"), // ic/16/arrow-right-circle
            iconColor: .green, // System color/active
            iconSize: 16,
            spacing: 2,
            title: .init(
                textFont: .footnote, // Text/Body S/R_12×16_0%
                textColor: .secondary // Text/placeholder
            ),
            value: .init(
                textFont: .headline, // Text/H4/M_16×24_0%
                textColor: .primary // Text/secondary
            ),
            valueSpacing: 9
        )
    }
}

extension ProductCard {
    
    static func preview(
        md5Hash: String = UUID().uuidString,
        options: [Option] = [
            .init(title: "Открытие ", value: "Бесплатно"),
            .init(title: "Обслуживание ", value: "Бесплатно"),
        ],
        title: String = "!Кредитная карта",
        subtitle: String = "!Бесплатное открытие и обслуживание"
    ) -> Self {
        
        return .init(md5Hash: md5Hash, options: options, title: title, subtitle: subtitle)
    }
}

struct ProductCardViewConfig: Equatable {
    
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let edges: EdgeInsets
    let spacing: CGFloat
    let header: HeaderConfig
    let label: LabelConfig
}

extension ProductCardViewConfig {
}

extension ProductCardViewConfig {
    
    struct HeaderConfig: Equatable {
        
        let title: TextConfig
        let subtitle: TextConfig
        let spacing: CGFloat
    }
    
    struct LabelConfig: Equatable {
        
        let icon: IconConfig
        let option: OptionConfig
        let title: TitleConfig
        let spacing: CGFloat
    }
}

extension ProductCardViewConfig.LabelConfig {
    
    struct IconConfig: Equatable {
        
        let cornerRadius: CGFloat
        let shadow: ShadowConfig
        let size: CGSize
    }
    
    struct OptionConfig: Equatable {
        
        let icon: Image
        let iconColor: Color
        let iconSize: CGFloat
        let spacing: CGFloat
        let title: TextConfig
        let value: TextConfig
        let valueSpacing: CGFloat
    }
    
#warning("Remove")
    struct TitleConfig: Equatable {
        let spacing: CGFloat
    }
}

extension ProductCardViewConfig.LabelConfig.IconConfig {
    
    struct ShadowConfig: Equatable {
        
        let color: Color
        let offset: CGFloat
        let blur: CGFloat
        let size: CGSize
    }
}

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
    
#warning("replace `Color.red` with injected view!")
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
