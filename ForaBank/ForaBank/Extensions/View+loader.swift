//
//  View+loader.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.01.2024.
//

import SwiftUI

extension View {
    
    func loader(isLoading: Bool) -> some View {
        
        self.modifier(LoaderWrapper(isLoading: isLoading))
    }
}

struct LoaderWrapper: ViewModifier {
    
    let isLoading: Bool
    
    func body(content: Content) -> some View {
 
        ZStack {
            
            content
            
            SpinnerView(viewModel: .init())
                .opacity(isLoading ? 1 : 0)
        }
    }
}
