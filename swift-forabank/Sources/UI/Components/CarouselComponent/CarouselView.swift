//
//  CarouselView.swift
//
//
//  Created by Disman Dmitry on 22.01.2024.
//

import SwiftUI

struct CarouselView: View {
    
    let state: State
    let event: (Event) -> Void
    
    var body: some View {
                
        EmptyView()
            .onAppear(perform: { event(.appear) })
    }
}
