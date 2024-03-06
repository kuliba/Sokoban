//
//  SelectorView.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import SwiftUI

struct SelectorView: View {
    
    typealias Selector = CarouselState.ProductTypeSelector
    
    let state: Selector
    let event: (Product.ID.ProductType) -> Void
    let configuration: SelectorConfiguration
        
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: configuration.appearance.itemSpacing) {
                                
                ForEach(state.items.uniqueValues, id: \.self) { productType in
                    
                    Group {
                        
                        labelView(
                            title: productType.pluralName,
                            shouldSelect: productType == state.selected,
                            appearance: configuration.appearance,
                            style: configuration.style) {
                                
                                event(productType)
                            }

                    }
                    .frame(height: configuration.carouselSizing.selectorOptionsFrameHeight)
                    .accessibilityIdentifier("optionProductTypeSelection")
                }
            }
        }
    }
}

extension SelectorView {
    
    @ViewBuilder
    private func labelView(
        title: String,
        shouldSelect: Bool,
        appearance: SelectorConfiguration.Appearance,
        style: SelectorConfiguration.Style,
        action: @escaping () -> Void
    ) -> some View {
        
        let optionTextForeground = shouldSelect
            ? style.colors.optionTextForeground.selected
            : style.colors.optionTextForeground.default
        
        let optionShapeForeground = shouldSelect
            ? style.colors.optionShapeForeground.selected
            : style.colors.optionShapeForeground.default
        
        Group {
            switch appearance {
            case .template:
                
                Text(title)
                    .font(style.fonts.optionTextFont)
                    .foregroundColor(optionTextForeground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().foregroundColor(optionShapeForeground))
                
            case .products, .productsSmall:
                
                HStack(spacing: 4) {
                    
                    Circle()
                        .frame(width: 4, height: 4, alignment: .center)
                        .foregroundColor(optionShapeForeground)
                    
                    Text(title)
                        .font(style.fonts.optionTextFont)
                        .foregroundColor(optionTextForeground)
                        .padding(.vertical, 6)
                }
            }
        }
        .onTapGesture {
            action()
        }
    }
}
