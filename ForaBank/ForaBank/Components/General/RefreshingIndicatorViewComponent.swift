//
//  RefreshViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 09.03.2022.
//

import SwiftUI

//MARK: - View Model

extension RefreshingIndicatorView {
    
    class ViewModel: ObservableObject {
        
        @Published var isActive: Bool
        
        init(isActive: Bool) {
            
            self.isActive = isActive
        }
    }
}

//MARK: - View

struct RefreshingIndicatorView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        if viewModel.isActive == true {
            
            ZStack {
                
                AnimatedRectView(color: .mainColorsRed, width: 100, duration: 2.0)
                AnimatedRectView(color: .mainColorsRed, width: 200, duration: 2.0, delay: 1.0)
                AnimatedRectView(color: .mainColorsBlack, width: 200, duration: 2.0, delay: 0.3)
                AnimatedRectView(color: .mainColorsBlack, width: 100, duration: 2.0, delay: 1.3)
            }
            .frame(height: 3)
            
        } else {
            
            Color.clear
                .frame(height: 1)
        }
    }
}

extension RefreshingIndicatorView {
    
    struct AnimatedRectView: View {
        
        var color: Color = .black
        var width: CGFloat = 100
        var opacity: Double = 1.0
        var duration: TimeInterval = 1.0
        var delay: TimeInterval = 0
        
        @State private var isAnimate: Bool = false

        var body: some View {
            
            GeometryReader { proxy in
                
                Rectangle()
                    .foregroundColor(color)
                    .opacity(opacity)
                    .frame(width: width)
                    .offset(.init(width: isAnimate ? proxy.frame(in: .local).width + width
                                                   : -width, height: 0))
                    .animation(.easeInOut(duration: duration)
                        .repeatForever(autoreverses: false).delay(delay))
                    .animation(nil)
            }
            .onAppear {
                
                withAnimation {
                    
                    isAnimate = true
                }
            }
        }
    }
}

struct RefreshView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshingIndicatorView(viewModel: .init(isActive: true))
            .previewLayout(.fixed(width: 375, height: 20))
    }
}
