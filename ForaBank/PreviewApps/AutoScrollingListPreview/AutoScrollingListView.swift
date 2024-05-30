//
//  AutoScrollingListView.swift
//  AutoScrollingListPreview
//
//  Created by Igor Malyarov on 29.05.2024.
//

import SwiftUI

struct AutoScrollingListView<Item, ItemView>: View
where Item: Identifiable & Equatable,
      ItemView: View {
    
    let items: [Item]
    let itemView: (Item) -> ItemView
    
    var body: some View {
        
        ScrollViewReader { proxy in
            
            ScrollView {
                
                LazyVStack {
                    
                    ForEach(items, content: itemView)
                }
            }
            .onAppear { scrollToLast(proxy) }
            .onChange(of: items.map(\.id)) { scrollToLast(proxy, iDs: $0) }
        }
    }
    
    private func scrollToLast(
        _ proxy: ScrollViewProxy
    ) {
        if let lastItem = items.last {
            
            withAnimation {
                
                proxy.scrollTo(lastItem.id, anchor: .bottom)
            }
        }
    }
    
    private func scrollToLast(
        _ proxy: ScrollViewProxy,
        iDs: [Item.ID]
    ) {
        if let last = iDs.last {
            
            withAnimation {
                
                proxy.scrollTo(last, anchor: .bottom)
            }
        }
    }
}
