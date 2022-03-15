//
//  FullScreenCoverLagacyModifier.swift
//  ForaBank
//
//  Created by Max Gribov on 13.03.2022.
//

import SwiftUI

struct FullScreenCoverLegacy<ViewModel, CoverContent: View>: ViewModifier {
    
    @Binding var viewModel: ViewModel?
    let coverBackgroundColor: Color
    let coverContent: (ViewModel) -> CoverContent
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(viewModel: Binding<ViewModel?>, coverBackgroundColor: Color = .white, @ViewBuilder  coverContent: @escaping (ViewModel) -> CoverContent) {
        
        self._viewModel = viewModel
        self.coverBackgroundColor = coverBackgroundColor
        self.coverContent = coverContent
    }
    
    func body(content: Content) -> some View {
        
        GeometryReader { geo in
            
            ZStack {
                
                Color.clear
                
                content
                
                if let viewModel = viewModel {
                    
                    withAnimation {
                        
                        ZStack {
                            
                            coverBackgroundColor
                            coverContent(viewModel)
                        }
                        .animation(.spring())
                        .transition(.move(edge: .bottom))
                    }
                }
            }
        }
    }
}

extension View {
    
    func fullScreenCoverLegacy<ViewModel, Content: View>(viewModel: Binding<ViewModel?>, coverBackgroundColor: Color = .white, @ViewBuilder content: @escaping (ViewModel) -> Content) -> some View {
        
        modifier(FullScreenCoverLegacy(viewModel: viewModel, coverBackgroundColor: coverBackgroundColor, coverContent: content))
    }
}
