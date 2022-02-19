
//
//  PaymentsTaxesButtonInfoCellViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.02.2022.
//

import SwiftUI

extension PaymentsTaxesButtonInfoCellView {
    
    class ViewModel: PaymentsParameterViewModel {
        internal init(icon: Image, title: String, subTitle: String, action: @escaping (ViewModel.ID) -> Void) {
            
            self.icon = icon
            self.title = title
            self.subTitle = subTitle
            self.action = action
        }
        init(parameter: Payments.Parameter.Service, action: @escaping (ViewModel.ID) -> Void) {
            
            self.icon = Image("")
            self.title = parameter.title
            self.subTitle = parameter.description
            self.action = action
        }
        
        let id = UUID()
        let icon: Image
        let title: String
        let subTitle: String
        
        let action: (ViewModel.ID) -> Void
        
    }
    
}

struct PaymentsTaxesButtonInfoCellView: View {
    
    let viewModel: PaymentsTaxesButtonInfoCellView.ViewModel
    
    var body: some View {
        
        Button {
            
            viewModel.action(viewModel.id)
            
        } label: {
            
            HStack(spacing: 10) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: 8)  {
                    Text(viewModel.title)
                        .font(Font.custom("Inter-Medium", size: 16))
                        .foregroundColor(Color(hex: "#1C1C1C"))
                    Text(viewModel.subTitle)
                        .font(Font.custom("Inter-Regular", size: 12))
                        .foregroundColor(Color(hex: "#999999"))
                    
                }
                Spacer()
            }
        }
    }
}


struct PaymentsTaxesButtonInfoCellView_Previews: PreviewProvider {
    static var previews: some View {
        
        PaymentsTaxesButtonInfoCellView(viewModel: .init(icon: Image("qr_Icon"), title: "content", subTitle: "Налоги ", action: {_ in }))
            .previewLayout(.fixed(width: 375, height: 56))
    }
    
}



