//
//  TipView.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI

public struct TipViewConfiguration {
    
    let titleFont: Font
    let titleForeground: Color
    let backgroundView: Color
    
    public init(
        titleFont: Font,
        titleForeground: Color,
        backgroundView: Color
    ) {
        self.titleFont = titleFont
        self.titleForeground = titleForeground
        self.backgroundView = backgroundView
    }
}

struct TipView: View {
    
    let viewModel: TipViewModel
    let configuration: TipViewConfiguration
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            icon(with: viewModel.imageName)
            title(configuration: configuration)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(configuration.backgroundView)
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
    
    private func title(configuration: TipViewConfiguration) -> some View {
        
        Text(viewModel.text)
            .font(configuration.titleFont)
            .lineLimit(2)
            .lineSpacing(5)
            .foregroundColor(configuration.titleForeground)
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
            ),
            configuration: .init(
                titleFont: .body,
                titleForeground: .black,
                backgroundView: .gray
            )
        )
        .previewLayout(.sizeThatFits)
        .padding(8)
    }
}

