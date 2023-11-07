//
//  TipView.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

struct TipView: View {
    
    let viewModel: TipViewModel
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            icon(with: viewModel.imageName)
            title()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2).edgesIgnoringSafeArea([]))
        .cornerRadius(90)
    }
    
    private func icon(with imageName: String) -> some View {
        
        ZStack {
            
            Circle()
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
            
            Image(imageName)
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
    
    private func title() -> some View {
        
        Text(viewModel.text)
            .font(.subheadline)
            .lineLimit(2)
            .lineSpacing(5)
            .foregroundColor(.gray.opacity(0.2))
            .padding(.trailing, 40)
    }
}

// MARK: - Previews

struct PaymentHintView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TipView(
            viewModel: .init(
                imageName: "ellipsis.message",
                text: "Выберите счет карты, к которому будет привязан стикер"
            )
        )
        .previewLayout(.sizeThatFits)
        .padding(8)
    }
}

