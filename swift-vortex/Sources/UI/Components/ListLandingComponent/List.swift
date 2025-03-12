//
//  List.swift
//
//
//  Created by Дмитрий Савушкин on 21.02.2025.
//

import Foundation
import SwiftUI

public struct List: View {
    
    private let items: Items
    private let config: Config
    private let factory: ImageViewFactory
    
    public init(
        items: Items,
        config: Config,
        factory: ImageViewFactory
    ) {
        self.items = items
        self.config = config
        self.factory = factory
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: config.spacing) {
            
            items.title.map {
                $0.text(withConfig: config.title)
                    .accessibilityIdentifier("ItemsTitle")
            }
            
            ForEach(items.list, id: \.titleWithSubtitle, content: itemView)
                .accessibilityIdentifier("Items")
        }
        .padding(.vertical, config.paddings.vertical)
        .padding(.horizontal, config.paddings.horizontal)
        .background(config.background)
        .cornerRadius(12)
    }
    
    private func itemView (
        item: Items.Item
    ) -> some View {
        
        HStack(alignment: .center, spacing: config.spacing) {
            
            factory.makeIconView(item.md5hash)
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40, alignment: .center)
                .clipShape(Circle())
                .accessibilityIdentifier("ItemIcon")
            
            titleWithSubtitle(item)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func titleWithSubtitle(
        _ item: Items.Item
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            item.title.text(withConfig: config.item.title)
                .accessibilityIdentifier("ItemTitle")
            
            if let subtitle = item.subtitle, !subtitle.isEmpty {
                subtitle.text(withConfig: config.item.subtitle)
                    .accessibilityIdentifier("ItemSubtitle")
            }
        }
    }
}

private extension Items.Item {
    
    var titleWithSubtitle: String { title + (subtitle ?? "") }
}

