
//
//  PaymentsTaxesButtonInfoCellViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.02.2022.
//

import SwiftUI

extension PaymentsTaxesButtonInfoCellViewComponent {
    
    struct ViewModel: Identifiable {
        
        let id = UUID()
        let icon: Image
        let title: String
        let subTitle: String
        
        let action: (ViewModel.ID) -> Void
        
    }
    
}

struct PaymentsTaxesButtonInfoCellViewComponent: View {
    
    let viewModel: PaymentsTaxesButtonInfoCellViewComponent.ViewModel
    
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


struct PaymentsTaxesButtonInfoCellViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        PaymentsTaxesButtonInfoCellViewComponent(viewModel: .init(icon: Image("qr_Icon"), title: "content", subTitle: "Налоги ", action: {_ in }))
            .previewLayout(.fixed(width: 375, height: 56))
    }
    
}



