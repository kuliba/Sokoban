//
//  ProductProfileDetailCircleProgressViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 17.06.2022.
//

import SwiftUI

//MARK: - View Model

extension ProductProfileDetailView.ViewModel {
    
    struct CircleProgressViewModel {
        
        let progress: Double
        let primaryColor: Color
        let secondaryColor: Color
        let action: () -> Void
    }
}

//MARK: - View

extension ProductProfileDetailView {
    
    struct CircleProgressView: View {
        
        let viewModel: ProductProfileDetailView.ViewModel.CircleProgressViewModel
        
        var body: some View {
            
            ZStack {
                
                CircleSegmentedBarView(
                    progress: .constant(viewModel.progress),
                    width: 4,
                    primaryColor: viewModel.primaryColor,
                    secondaryColor: viewModel.secondaryColor
                )
                    .frame(width: 96, height: 96)
                
                Button(action: viewModel.action) {
                    
                    ZStack {
                        
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.mainColorsBlackMedium)
                            
                        Image.ic24AlertCircle
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.iconGray)
                    }
                    
                }.buttonStyle(PushButtonStyle())
            }
        }
    }
}

//MARK: - Preview

struct ProductProfileDetailCircleProgressViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
       
        Group {
            
            ZStack {
                
                Color.black
                ProductProfileDetailView.CircleProgressView(viewModel: .sample)
            }
            .previewLayout(.fixed(width: 200, height: 200))
        }
    }
}

//MARK: - Preview Content

extension ProductProfileDetailView.ViewModel.CircleProgressViewModel {
    
    static let sample = ProductProfileDetailView.ViewModel.CircleProgressViewModel(progress: 0.0002, primaryColor: .mainColorsRed, secondaryColor: .textPlaceholder, action: {})
}
