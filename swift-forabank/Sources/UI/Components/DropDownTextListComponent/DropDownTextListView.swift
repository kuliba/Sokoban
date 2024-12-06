//
//  DropDownTextListView.swift
//
//
//  Created by Valentin Ozerov on 05.12.2024.
//

import SwiftUI

public struct DropDownTextListView: View {
    
    @State private(set) var selectedItem: Item?

    private let config: Config
    private let list: TextList
    
    public init(config: Config, list: TextList) {
        self.config = config
        self.list = list
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            list.title.map { text in
                
                VStack {
                    
                    text.text(withConfig: config.fonts.title)
                        .modifier(
                            PaddingsModifier(
                                horizontal: config.layouts.horizontalPadding,
                                vertical: config.layouts.verticalPadding
                            )
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityIdentifier("ListTitle")
                    
                    config.colors.divider
                        .frame(height: 0.5)
                }
            }
            
            ForEach(list.items, content: itemView)
        }
        .modifier(BackgroundAndCornerRadiusModifier(
            background: config.colors.background,
            cornerRadius: config.cornerRadius
        ))
    }
    
    private func itemView(item: Item) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            titleAndSubTitleView(for: item)
            
            if list.items.last != item {
                
                config.colors.divider
                    .frame(height: 0.5)
            }
        }
    }
    
    private func titleAndSubTitleView(for item: Item) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Button(
                action: { withAnimation { selectedItem = selectedItem == item ? nil : item } },
                label: { titleView(for: item) }
            )
            
            if selectedItem == item {

                subTitleView(item.subTitle)
            }
        }
    }
    
    private func titleView(for item: Item) -> some View {
        return HStack {
            
            item.title.text(withConfig: config.fonts.itemTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("Title")
            
            config.chevronDownImage
                .foregroundColor(.gray)
                .rotationEffect(selectedItem == item ? .degrees(180) : .degrees(0))
                .accessibilityIdentifier("ItemChevron")
        }
        .modifier(PaddingsModifier(horizontal: config.layouts.horizontalPadding))
        .frame(height: config.layouts.itemHeight)
    }
    
    private func subTitleView(_ subTitle: String) -> some View {
        return Text(subTitle)
            .multilineTextAlignment(.leading)
            .modifier(PaddingsModifier(horizontal: config.layouts.horizontalPadding))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("SubTitle")
    }
}

public extension DropDownTextListView {
    
    typealias Config = DropDownTextListConfig
    typealias TextList = DropDownTextList
    typealias Item = DropDownTextList.Item
}
