//
//  List.swift
//
//
//  Created by Дмитрий Савушкин on 21.02.2025.
//

import Foundation
import SwiftUI

struct List: View {
    
    let items: Items
    let config: Config
    let factory: ImageViewFactory
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: config.spacing) {
            
            items.title.map {
                $0.text(withConfig: config.title)
                    .accessibilityIdentifier("ItemsTitle")
            }
            
            ForEach(items.list, content: itemView)
                .accessibilityIdentifier("Items")
        }
    }
    
    private func itemView (
        item: Items.Item
    ) -> some View {
        
        HStack(spacing: config.spacing) {
            
            factory.makeIconView(item.md5hash)
                .aspectRatio(contentMode: .fit)
                .accessibilityIdentifier("ItemIcon")
            
            VStack(alignment: .leading, spacing: 0) {
                
                item.title.text(withConfig: config.item.title)
                    .accessibilityIdentifier("ItemTitle")
                
                item.subtitle.map {
                    $0.text(withConfig: config.item.subtitle)
                        .accessibilityIdentifier("ItemSubtitle")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
