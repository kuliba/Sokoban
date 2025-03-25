//
//  PlaceholderLandingView.swift
//
//
//  Created by Дмитрий Савушкин on 24.03.2025.
//

import SwiftUI
import UIPrimitives

struct PlaceholderLandingView: View {
    
    let config: PlaceholderConfig
    let isAnimated: Bool
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: config.cover.verticalSpacing) {
                
                withShimmering {
                    
                    coverView()
                }
                
                Group {
                    
                    withShimmering {
                        
                        itemsView()
                    }
                    
                    withShimmering {
                        
                        listView()
                    }
                }
                .padding(.horizontal, config.hpadding)
                .padding(.vertical, config.vpadding)
                .background(config.background)
                .cornerRadius(config.cornerRadius)
                .padding(.horizontal, config.hpadding)
                
                dropDownView()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .safeAreaInset(edge: .bottom) {
            
            withShimmering(heroButton)
                .padding(.top, 18)
                .background(.white)
        }
    }
    
    private func dropDownView() -> some View {
        
        VStack(spacing: config.dropDownList.vspacing) {
            
            ForEach(0..<config.dropDownList.itemsCount) { _ in
                
                dropDownPlaceholderView()
            }
        }
        .padding(.horizontal, config.dropDownList.hpadding)
    }
    
    private func listView() -> some View {
        
        VStack(spacing: config.list.vspacing) {
            
            ForEach(0..<config.list.countItems) { _ in
                secondItemView()
            }
        }
    }
    
    private func itemsView() -> some View {
        
        VStack(spacing: config.items.verticalSpacing) {
            
            config.items.itemColor
                .frame(height: config.items.titleItemHeight)
                .cornerRadius(90)
            
            VStack(spacing: 16) {
                
                ForEach(0..<config.items.countItems) { _ in
                    optionPlaceholderView()
                }
            }
        }
    }
    
    private func coverView() -> some View {
        
        ZStack {
            
            config.cover.coverColor
            
            VStack(spacing: config.cover.itemsSpacing) {
                
                itemsPlaceholderView()
                itemsPlaceholderView()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, config.cover.itemsLeadingPadding)
        }
        .frame(height: 703)
    }
    
    private func heroButton() -> some View {
        
        Color.gray
            .frame(height: config.heroButton.height)
            .cornerRadius(config.heroButton.cornerRadius)
            .padding(.horizontal, config.heroButton.hpadding)
    }
    
    private func withShimmering(
        _ content: () -> some View
    ) -> some View {
        
        content()
            ._shimmering(isActive: isAnimated)
    }
    
    
    @ViewBuilder
    func dropDownPlaceholderView() -> some View {
        
        withShimmering {
            
            HStack(spacing: config.dropDownList.hspacingItem) {
                
                config.dropDownList.colorItem
                    .frame(
                        width: config.dropDownList.itemIconSize,
                        height: config.dropDownList.itemIconSize
                    )
                    .cornerRadius(config.dropDownList.itemIconSize/2)
                
                config.dropDownList.colorItem
                    .frame(height: config.dropDownList.lineHeight)
                    .cornerRadius(config.dropDownList.cornerRadius)
            }
        }
    }
    
    @ViewBuilder
    func secondItemView() -> some View {
        
        withShimmering {
            
            config.list.colorItem
                .frame(height: config.list.itemHeight)
                .cornerRadius(config.list.cornerRadius)
        }
    }
    
    @ViewBuilder
    func optionPlaceholderView() -> some View {
        
        HStack(spacing: config.items.item.hspacing) {
            
            config.items.item.color
                .frame(
                    width: config.items.item.iconSize,
                    height: config.items.item.iconSize
                )
                .cornerRadius(config.items.item.iconSize/2)
            
            VStack(spacing: config.items.item.vspacing) {
                
                config.items.item.color
                    .frame(height: config.items.item.heightTitle)
                    .cornerRadius(config.items.item.cornerRadius)
                
                config.items.item.color
                    .frame(height: config.items.item.heightSubtitle)
                    .cornerRadius(config.items.item.cornerRadius)
            }
        }
    }
    
    func itemsPlaceholderView() -> some View {
        
        withShimmering {
            
            VStack(spacing: config.cover.vspacingItems) {
                
                config.cover.item.color
                    .frame(
                        width: config.cover.item.weight,
                        height: config.cover.item.height
                    )
                    .cornerRadius(config.cover.item.cornerRadius)
                
                config.cover.item.color
                    .frame(
                        width: config.cover.item.weight,
                        height: config.cover.item.height
                    )
                    .cornerRadius(config.cover.item.cornerRadius)
                
                config.cover.item.color
                    .frame(
                        width: config.cover.item.weight,
                        height: config.cover.item.height
                    )
                    .cornerRadius(config.cover.item.cornerRadius)
            }
        }
    }
}

#Preview {
    
    return PlaceholderLandingView(
        config: .preview,
        isAnimated: true
    )
}

#Preview {
    
    PlaceholderLandingView(
        config: .preview,
        isAnimated: false
    )
}
