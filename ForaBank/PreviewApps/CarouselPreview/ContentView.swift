//
//  ContentView.swift
//  CarouselPreview
//
//  Created by Igor Malyarov on 15.02.2024.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
       
        VStack(spacing: 40) {
            
            CarouselMainView(
                products: .preview,
                needShowSticker: true
            )
            .padding()
            
            CarouselMainView(
                products: .preview,
                needShowSticker: false
            )
            .padding()
        }
    }
}
