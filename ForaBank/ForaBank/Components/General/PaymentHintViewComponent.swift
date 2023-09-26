//
//  PaymentHintViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 26.09.2023.
//

import Foundation
import SwiftUI

extension PaymentHintView {
    
    struct ViewModel {
        
        let image: Image
        let text: String
    }
}

struct PaymentHintView: View {
    
    let viewModel: PaymentHintView.ViewModel
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            ZStack {
                
                Circle()
                    .foregroundColor(.white)
                    .frame(.init(width: 32, height: 32))
                
                viewModel.image
                    .resizable()
                    .frame(.init(width: 24, height: 24))
            }
            
            Text(viewModel.text)
                .font(.textBodyMR14200())
                .lineLimit(2)
                .lineSpacing(5)
                .foregroundColor(.textSecondary)
                .padding(.trailing, 40)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.mainColorsGrayLightest)
        .cornerRadius(90)
    }
}

// MARK: - Previews

struct PaymentHintView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentHintView(viewModel: .init(
                image: .ic24IconMessage,
                text: "Выберите счет карты, к которому будет привязан стикер")
            )
            .previewLayout(.sizeThatFits)
            .padding(8)
            
        }
    }
}
