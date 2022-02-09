//
//  PaymentsTaxesInputCellViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI

extension PaymentsTaxesInputCellViewComponent {
    
    struct ViewModel {
        
        let logo: Image
        let title: String
        let action: (String) -> Void
    }
}

struct PaymentsTaxesInputCellViewComponent: View {
    
    let viewModel: PaymentsTaxesInputCellViewComponent.ViewModel
    @State var content: String = ""
    
    var body: some View {
        HStack(spacing: 10) {
            
            viewModel.logo
                .resizable()
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 10)  {
                
                Text(viewModel.title)
                    .font(Font.custom("Inter-Regular", size: 16))
                    .foregroundColor(Color(hex: "#999999"))
                
                TextField(
                    "placeholder",
                    text: $content,
                    onEditingChanged: { (isBegin) in
                        if isBegin {
                            /// Валидация
                        } else {
                            viewModel.action(content)
                        }
                    },
                    onCommit: {
                        /// Возвращаем фоновый текст, если он есть. Уточнить
                    }
                )
                    .foregroundColor(Color(hex: "#1C1C1C"))
                    .font(Font.custom("Inter-Medium", size: 14))
                
                Divider()
                    .frame(height: 1)
                    .background(Color(hex: "#EAEBEB"))
                
            } .textFieldStyle(DefaultTextFieldStyle())
        }
    }
}


struct PaymentsTaxesInputCellViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        PaymentsTaxesInputCellViewComponent(viewModel: .init(logo: Image("fora_white_back_bordered"),title: "Title", action:{_ in }))
            .previewLayout(.fixed(width: 375, height: 56))
    }
}


