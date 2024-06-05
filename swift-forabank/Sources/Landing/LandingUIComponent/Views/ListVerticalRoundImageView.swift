//
//  ListVerticalRoundImageView.swift
//  NewComponents
//
//  Created by Andrew Kurdin on 18.09.2023.
//

import SwiftUI
import Combine
import UIPrimitives

struct ListVerticalRoundImageView: View {
    
    @ObservedObject var model: ViewModel
    let config: UILanding.List.VerticalRoundImage.Config
    
    @State private var showAll = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            model.data.title.map { Header(text: $0, config: config) }
            
            LazyVStack(alignment: .leading, spacing: config.spacings.lazyVstack) {
                
                ForEach(model.list(showAll: showAll), content: itemView(item:))
                
                if let _ = model.data.displayedCount {
                    buttonShowAll
                }
            }
            .padding(.top, 7) // минус магические 6 с item
            .padding(.bottom, config.listVerticalPadding)
        }
        .background(config.componentSettings.background)
        .cornerRadius(config.componentSettings.cornerRadius)
        .padding(.horizontal, config.padding.horizontal)
        .padding(.vertical, config.padding.vertical)
    }
    
    private func itemView (
        item: UILanding.List.VerticalRoundImage.ListItem
    ) -> some View {
        
        Item(
            config: config,
            item: item,
            image: model.image(byMd5Hash: item.md5hash),
            action: { model.action(for: item) })
    }
    
    private var buttonShowAll: some View {
        
        Button(action: { showAll.toggle() }) {
            
            HStack(spacing: config.spacings.buttonHStack) {
                
                ZStack(alignment: .center) {
                    
                    Circle()
                        .frame(width: config.item.imageWidthHeight, height: config.item.imageWidthHeight)
                        .foregroundColor(.white)
                        .accessibilityIdentifier("VerticalRoundbuttonShowAllCircle")
                    
                    Image(systemName: "ellipsis")
                        .foregroundColor(config.buttonSettings.ellipsisForegroundColor)
                        .accessibilityIdentifier("VerticalRoundbuttonShowAllImage")
                }
                
                Text(showAll ? model.data.dropButtonCloseTitle ?? "" : model.data.dropButtonOpenTitle ?? "")
                    .font(config.buttonSettings.text.font)
                    .foregroundColor(config.buttonSettings.text.color)
                    .accessibilityIdentifier("VerticalRoundbuttonShowAllText")
                
                Spacer()
            }
            .padding(.horizontal, config.buttonSettings.padding.horizontal)
            .padding(.vertical, config.buttonSettings.padding.vertical)
        }
    }
    
    struct Header: View {
        
        let text: String
        let config: UILanding.List.VerticalRoundImage.Config
        
        var body: some View {
            
            VStack(alignment: .leading) {
                
                Text(text)
                    .font(config.title.font)
                    .foregroundColor(config.title.color)
                    .padding(.horizontal, config.title.paddingHorizontal)
                    .padding(.top, config.title.paddingTop)
                    .accessibilityIdentifier("VerticalRoundHeader")
                
                config.divider
                    .frame(height: 0.5)
            }
        }
    }
    
    struct Item: View {
        
        let config: UILanding.List.VerticalRoundImage.Config
        let item: UILanding.List.VerticalRoundImage.ListItem
        let image: Image?
        let action: () -> Void
        
        var body: some View {
            
            Button(action: action) {
                
                HStack(alignment: config.item.hstackAlignment, spacing: config.spacings.itemHstack) {
                    
                    ImageView(image: image, config: config.item)
                    
                    VStack(alignment: .leading, spacing: config.spacings.itemVStackBetweenTitleSubtitle) {
                        if let subInfo = item.subInfo, !subInfo.isEmpty {
                            
                            TitleView(item: item, config: config)
                                .accessibilityIdentifier("VerticalRoundItemTitle")

                            Text(subInfo)
                                .font(config.item.font.subtitle)
                                .foregroundColor(config.item.color.subtitle)
                                .multilineTextAlignment(.leading)
                                .accessibilityIdentifier("VerticalRoundItemText")
                        } else {
                            TitleView(item: item, config: config)
                        }
                    }
                }
                .padding(.horizontal, config.item.padding.horizontal)
                .padding(.vertical, config.item.padding.vertical)
            }
            .disabled(item.disableAction)
        }
    }
    
    struct TitleView: View {
        
        let item: UILanding.List.VerticalRoundImage.ListItem
        let config: UILanding.List.VerticalRoundImage.Config
        
        var body: some View {
            
            item.title.map {
                
                Text($0)
                    .font(config.item.font.titleWithOutSubtitle)
                    .foregroundColor(config.item.color.title)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    struct ImageView: View {
        
        let image: Image?
        let config: UILanding.List.VerticalRoundImage.Config.ListItem
        
        var body: some View {
            
            switch image {
            case .none:
                Color.white
                    .cornerRadius(config.imageWidthHeight/2)
                    .frame(width: config.imageWidthHeight, height: config.imageWidthHeight)
                    .shimmering()
                    .accessibilityIdentifier("VerticalRoundItemIcon")
                
            case let .some(image):
                image
                    .resizable()
                    .cornerRadius(config.imageWidthHeight/2)
                    .frame(width: config.imageWidthHeight, height: config.imageWidthHeight)
                    .accessibilityIdentifier("VerticalRoundItemImage")
            }
        }
    }
}

struct ListVerticalRoundImageView_Previews: PreviewProvider {
    static var previews: some View {
        ListVerticalRoundImageView(
            model: .init(
                data: .defaultValue,
                images: [:],
                selectDetail: { _ in }),
            config: .default)
    }
}
