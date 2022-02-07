//
//  PaymentsTaxesInputCellViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI

extension PaymentsTaxesInputCellViewComponent {
    
    struct ViewModel: Identifiable {
        let id = UUID()
        let logo: Image
        let title: String
        let subTitle: String
        let action: (ViewModel.ID) -> Void
        
    }
    
    struct TextFieldModel {
        
        let icon: Image
        let action: () -> Void
    }
    
}

struct PaymentsTaxesInputCellViewComponent {
    
    struct PaymentsTaxesInputCell: View {
        let viewModel: PaymentsTaxesInputCellViewComponent.ViewModel
        let buttonViewModel:PaymentsTaxesInputCellViewComponent.TextFieldModel
        @State var text: String = ""
        var body: some View {
            HStack(spacing: 10) {
                
                viewModel.logo
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 10)  {
                    Text(viewModel.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.black)
                    
                    
                } .textFieldStyle(DefaultTextFieldStyle())
                
                
            } .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .leading
            )
        }
    }
}


struct PaymentsTaxesInputCellViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsTaxesInputCellViewComponent.PaymentsTaxesInputCell(viewModel: PaymentsTaxesInputCellViewComponent.ViewModel(logo: Image("fora_white_back_bordered"),
                                                                                                                               title: "Title",
                                                                                                                        subTitle: "SubTitle",         action: { _ in }),
                                                             buttonViewModel: PaymentsTaxesInputCellViewComponent.TextFieldModel(icon: Image("chevron-downnew"), action:{}))
            .previewLayout(.fixed(width: 375, height: 56))
    }
}


