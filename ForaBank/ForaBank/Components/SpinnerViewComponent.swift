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
    
    class ViewModel: ObservableObject {
        
        @Published var isAnimating: Bool
        
        init(isAnimating: Bool = true) {
            
            self.isAnimating = isAnimating
        }
    }
}

//MARK: - View

struct SpinnerView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            ActivityIndicatorView(isAnimating: $viewModel.isAnimating)
                .foregroundColor(.white)
        }
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
