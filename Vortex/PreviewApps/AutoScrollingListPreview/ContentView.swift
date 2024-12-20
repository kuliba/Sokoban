//
//  ContentView.swift
//  AutoScrollingListPreview
//
//  Created by Igor Malyarov on 29.05.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var items = (1...20).map(Item.init)
    
    var body: some View {
        
        NavigationView {
        
            VStack {
            
                AutoScrollingListView(items: items) {
                    
                    Text($0.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Auto-Scroll List")
            .toolbar(content: toolbar)
        }
    }
    
    private func addItem() {
        
        let newID = items.count + 1
        items.append(.init(id: newID))
    }
    
    private func toolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarTrailing) {
            
            Button(action: addItem) {
                
                Image(systemName: "plus")
            }
        }
    }
}

#Preview {
    ContentView()
}
