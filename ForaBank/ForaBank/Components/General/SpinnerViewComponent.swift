//
//  SpinnerViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 28.02.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension SpinnerView {
    
    struct ViewModel {

        let icon: Image
        
        init(icon: Image = .init("Logo Fora Bank")) {
            
            self.icon = icon
        }
    }
}

//MARK: - View

struct SpinnerView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
            
            SpinnerRefreshView(icon: viewModel.icon)
        }
        .navigationBarHidden(true)
    }
}

//MARK: - Private Helpers

fileprivate struct ActivityIndicatorView: UIViewRepresentable {
    
    @Binding var isAnimating: Bool

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        
        UIActivityIndicatorView(style: .large)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
