//
//  ContentView.swift
//  ReactiveRefreshScrollViewPreview
//
//  Created by Igor Malyarov on 01.03.2025.
//

import SwiftUI
import UIPrimitives
import VortexTools

final class ItemsModel: ObservableObject {
    
    @Published private(set) var items: [Item] = [.init()]
    
    func addItem() {
        
        items.append(.init())
    }
}

struct Item: Identifiable {
    
    let id: UUID
    
    init(id: UUID = .init()) {
        
        self.id = id
    }
}

struct ContentView: View {
    
    @StateObject var model: ItemsModel
    @StateObject var scrollModel: ReactiveRefreshScrollViewModel
    
    var body: some View {
        
        TabView {
            
            reactiveRefreshScrollView {
                
                VStack(spacing: 4) {
                    
                    ForEach(model.items, content: itemView)
                }
            }
            .tabItem { Text("Items") }
            
            reactiveRefreshScrollView {
                
                Color.green.opacity(0.1).frame(height: 200)
            }
            .tabItem { Text("Colors") }
            
            offsetReportingScrollView()
                .tabItem { Text("Offset") }
            
            offsetReportingScrollViewColors()
                .tabItem { Text("Offset2") }
        }
    }
}

private extension ContentView {
    
    func reactiveRefreshScrollView(
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        
        ReactiveRefreshScrollView(model: scrollModel) { offsetY in
            
            Text("reported offset: \(Int(offsetY).formatted())")
                .foregroundStyle(.orange)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            content()
        }
        .padding()
    }
    
    private func itemView(
        item: Item
    ) -> some View {
        
        Text("Item \(item.id.uuidString.suffix(4))")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 9)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func offsetReportingScrollView() -> some View {
        
        OffsetReportingScrollView { offsetY in
            
            VStack {
                
                Text(Int(offsetY).formatted())
                
                ForEach(model.items, content: itemView)
            }
        }
    }
    
    private func offsetReportingScrollViewColors() -> some View {
        
        OffsetReportingScrollView { offsetY in
            
            VStack {
                
                Color.green
                    .frame(height: 100)
                
                Text(Int(offsetY).formatted())
                
                Color.blue
                    .frame(height: 300)
            }
        }
    }
}
