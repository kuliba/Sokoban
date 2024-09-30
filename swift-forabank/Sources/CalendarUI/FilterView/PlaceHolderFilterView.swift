//
//  PlaceHolderFilterView.swift
//
//
//  Created by Дмитрий Савушкин on 20.09.2024.
//

import SwiftUI

struct PlaceHolderFilterView: View {
    
    let state: FilterState
    let config: FilterConfig
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width - 40
            
            VStack(alignment: .leading) {
                
                // MARK: - TransactionContainer, движение средств
                
                config.transactionTitle.title.text(withConfig: config.transactionTitle.titleConfig)
                    .padding(.bottom, 5)
                
                HStack(spacing: 8) {
                    ShimmerRectangle(width: width * 0.25)
                    ShimmerRectangle(width: width * 0.31)
                }
                .cornerRadius(16)
                .padding(.bottom, 20)
                
                // MARK: - FlexibleContainerButtons, категории
                
                config.categoryTitle.title.text(withConfig: config.categoryTitle.titleConfig)
                    .padding(.bottom, 5)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    HStack(spacing: 8) {
                        ShimmerRectangle(width: width * 0.33)
                        ShimmerRectangle(width: width * 0.36)
                        ShimmerRectangle(width: width * 0.14)
                    }
                    
                    HStack(spacing: 8) {
                        ShimmerRectangle(width: width * 0.45)
                        ShimmerRectangle(width: width * 0.36)
                    }
                    HStack(spacing: 8) {
                        ShimmerRectangle(width: width * 0.28)
                        ShimmerRectangle(width: width * 0.31)
                        ShimmerRectangle(width: width * 0.29)
                    }
                    HStack(spacing: 8) {
                        ShimmerRectangle(width: width * 0.4)
                        ShimmerRectangle(width: width * 0.38)
                    }
                    HStack(spacing: 8) {
                        ShimmerRectangle(width: width * 0.42)
                        ShimmerRectangle(width: width * 0.32)
                    }
                    
                    ShimmerRectangle(width: width * 0.63)
                }
                .cornerRadius(16)
            }
        }
    }
}

struct ShimmerRectangle: View {
    
    var width: CGFloat
    var height: CGFloat = 32
    var cornerRadius: CGFloat = 90
    var gradient: Gradient = Gradient(colors: [.init(red: Double(211/255), green: Double(211/255), blue: Double(211/255), opacity: 0.3)])

    var body: some View {
        
            SwiftUI.RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        gradient: gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: height)
                .shimmering()
    }
}
