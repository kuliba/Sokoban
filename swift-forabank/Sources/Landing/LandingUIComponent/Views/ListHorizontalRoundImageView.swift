//
//  ListHorizontalRoundImageView.swift
//  
//
//  Created by Andryusina Nataly on 27.08.2023.
//

import SwiftUI

typealias ComponentLHRI = Landing.ListHorizontalRoundImage
typealias ConfigLHRI = Landing.ListHorizontalRoundImage.Config

struct ListHorizontalRoundImageView: View {
    
    let model: ComponentLHRI
    let config: ConfigLHRI
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(config.backgroundColor)
            
            VStack(alignment: .leading, spacing: 16) {
                
                if let title = model.title {
                    
                    Text(title)
                        .font(config.title.font)
                        .foregroundColor(config.title.color)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack {
                        
                        ForEach(model.list) {
                            ItemView(item: $0, config: config)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 148)
        .padding(.horizontal)
    }
}

extension ListHorizontalRoundImageView {
    
    struct SubInfoView: View {
        
        let text: String
        let config: ConfigLHRI.Subtitle
        
        var body: some View {
            
            Text(text)
                .font(config.font)
                .foregroundColor(config.color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(config.background)
                .cornerRadius(12)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topTrailing)
        }
    }
}

extension ListHorizontalRoundImageView {
    
    struct ItemView: View {
        
        let item: ComponentLHRI.ListItem
        let config: ConfigLHRI
        
        var body: some View {
            
            Button(action: {} ) { //viewModel.onAction) 
                
                ZStack {
                    
                    VStack(spacing: 8) {
                        
                        item.image
                            .resizable()
                            .cornerRadius(28)
                            .frame(width: 56, height: 56)
                        
                        if let title = item.title {
                            
                            Text(title)
                                .font(config.detail.font)
                                .foregroundColor(config.detail.color)
                        }
                    }
                    if let text = item.subInfo {
                        
                        ListHorizontalRoundImageView.SubInfoView(
                            text: text,
                            config: config.subtitle)
                    }
                    
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct ListHorizontalRoundImageView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            ListHorizontalRoundImageView(
                model: .defaultValue,
                config: .defaultValue)
            .previewDisplayName("With title")
            
            ListHorizontalRoundImageView(
                model: .defaultValueWithoutTitle,
                config: .defaultValue)
            .previewDisplayName("Without title")
        }
    }
}
