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
    let event: (Product.ProductType) -> Void
    let config: SelectorConfig
        
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: config.itemSpacing) {
                                
                ForEach(state.items.uniqueValues, id: \.self) { productType in
                                            
                    labelView(
                        title: productType.pluralName,
                        shouldSelect: productType == state.selected,
                        config: config
                    ) {
                        event(productType)
                    }
                    .frame(height: config.optionConfig.frameHeight)
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
        config: SelectorConfig,
        action: @escaping () -> Void
    ) -> some View {
        
        let optionTextForeground = shouldSelect
            ? config.optionConfig.textForegroundSelected
            : config.optionConfig.textForeground
        
        let optionShapeForeground = shouldSelect
            ? config.optionConfig.shapeForegroundSelected
            : config.optionConfig.shapeForeground
        
        Group {
            
            Text(title)
                .font(config.optionConfig.textFont)
                .foregroundColor(optionTextForeground)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().foregroundColor(optionShapeForeground))
        }
        .onTapGesture {
            action()
        }
    }
}
