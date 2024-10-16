//
//  ContentView.swift
//  RefreshableScrollViewPreview
//
//  Created by Igor Malyarov on 16.10.2024.
//

import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    @State private var items = ["Item 1", "Item 2", "Item 3"]
    
    var body: some View {
        
        RefreshableScrollView(
            action: refreshData,
            showsIndicators: false,
            offsetForStartUpdate: -100,
            refreshCompletionDelay: 2.0
        ) {
            VStack {
                
                ForEach(items, id: \.self) {
                    
                    Text($0)
                        .padding(.horizontal)
                    
                    Divider()
                }
            }
        }
    }
    
    func refreshData() {
        
        print("refresh requested")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            items.append("New Item \(items.count + 1)")
            print("refresh performed")
        }
    }
}

#Preview {
    ContentView()
}
