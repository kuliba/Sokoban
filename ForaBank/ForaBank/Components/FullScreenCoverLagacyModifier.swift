//
//  FullScreenCoverLagacyModifier.swift
//  ForaBank
//
//  Created by Max Gribov on 13.03.2022.
//

import SwiftUI

struct FullScreenCoverLegacy<ViewModel, CoverContent: View>: ViewModifier {
    
    @Binding var viewModel: ViewModel?
    let coverContent: (ViewModel) -> CoverContent
    
    func body(content: Content) -> some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                Color.clear
                
                content
                
                if let viewModel = viewModel {
                    
                    withAnimation {
                        
                        ZStack {
                            
                            Color.white
                            coverContent(viewModel)
                        }
                        .animation(.spring())
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                    }
                }
            }
        }
    }
}

extension View {
    
    func fullScreenCoverLegacy<ViewModel, Content: View>(viewModel: Binding<ViewModel?>, content: @escaping (ViewModel) -> Content) -> some View {
        
        modifier(FullScreenCoverLegacy(viewModel: viewModel, coverContent: content))
    }
}
