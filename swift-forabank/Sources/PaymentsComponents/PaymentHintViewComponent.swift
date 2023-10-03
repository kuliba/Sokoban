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
                    .frame(width: 32, height: 32)
                
                viewModel.image
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            
            Text(viewModel.text)
                .font(.subheadline)
                .lineLimit(2)
                .lineSpacing(5)
                .foregroundColor(.gray.opacity(0.2))
                .padding(.trailing, 40)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.2).edgesIgnoringSafeArea([]))
        .cornerRadius(90)
    }
}

// MARK: - Previews

struct PaymentHintView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentHintView(viewModel: .init(
                image: Image(systemName: "ellipsis.message"),
                text: "Выберите счет карты, к которому будет привязан стикер")
            )
            .previewLayout(.sizeThatFits)
            .padding(8)
            
        }
    }
}
