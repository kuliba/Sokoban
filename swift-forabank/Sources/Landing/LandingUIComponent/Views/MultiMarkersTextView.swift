//
//  MultiMarkersText.swift
//  UIComponentsForFB
//
//  Created by Andrew Kurdin on 19.09.2023.
//

import SwiftUI

struct MultiMarkersTextView: View {
    
    let model: UILanding.Multi.MarkersText
    let config: UILanding.Multi.MarkersText.Config
    
    init(model: UILanding.Multi.MarkersText,
         config: UILanding.Multi.MarkersText.Config
    ){
        self.model = model
        self.config = config
    }
    
    var body: some View {
        
        if !model.list.isEmpty {
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading, spacing: config.internalContent.spacing) {
                    
                    ForEach(model.list) {
                            ItemView(
                                item: $0,
                                config: config,
                                foregroundColor: config.foregroundColor(model.backgroundColor))
                    }
                }
                .padding(.vertical, config.getVerticalPadding(model.style))
                .padding(.horizontal, config.getDoubleHorizontalPaddingForCornersView(model.style))
                .background(config.backgroundColor(model.backgroundColor))
                .cornerRadius(config.getCornerRadius(model.style))
                .accessibilityIdentifier("MultiMarkersTextBodyImage")
            }
            .padding(.leading, config.getLeadingPadding(model.style))
            .padding(.trailing, config.getTrailingPadding(model.style))
            .padding(.vertical, config.vstack.padding.vertical)
            .background(config.backgroundColor(model.style, model.backgroundColor))
            .accessibilityIdentifier("MultiMarkersTextBody")
        }
    }
}

extension MultiMarkersTextView {
    
    struct ItemView: View {
        
        let item: UILanding.Multi.MarkersText.Text
        let config: UILanding.Multi.MarkersText.Config
        let foregroundColor: Color
        var body: some View {
            
            HStack(alignment: .top) {
                
                Text(Image(systemName: "circle.fill")) // static
                    .font(.system(size: 4))
                    .offset(y: 6)
                    .accessibilityIdentifier("MultiMarkersTextItemImage")
                
                Text(item.rawValue)
                    .font(config.internalContent.textFont)
                    .accessibilityIdentifier("MultiMarkersTextItemText")
                
                Spacer(minLength: 0)
            }
            .padding(.leading, config.internalContent.lineTextLeadingPadding)
            .foregroundColor(foregroundColor)
        }
    }
}

struct MultiMarkersText_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MultiMarkersTextView(
                model: .defaultModel1,
                config: .defaultConfig)
            
            MultiMarkersTextView(
                model: .defaultModel2,
                config: .defaultConfig)
            
            MultiMarkersTextView(
                model: .defaultModel3,
                config: .defaultConfig)
        }
        .background(Color.gray)
    }
}
