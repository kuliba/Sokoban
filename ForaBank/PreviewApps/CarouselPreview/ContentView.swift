//
//  ContentView.swift
//  CarouselPreview
//
//  Created by Igor Malyarov on 15.02.2024.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        CarouselMainView(
            products: .preview,
            sticker: .sticker
        )
        .padding()
    }
}
