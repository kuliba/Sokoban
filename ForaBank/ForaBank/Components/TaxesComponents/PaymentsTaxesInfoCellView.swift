//
//  CellViewType_1.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI

extension PaymentsTaxesInfoCellView {
    
    struct ViewModel: Identifiable {
        let id = UUID()
        let icon: Image
        let content: String
        let description: String
        let action: (ViewModel.ID) -> Void
    }
}

struct PaymentsTaxesInfoCellView: View {
    
    let viewModel: PaymentsTaxesInfoCellView.ViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            viewModel.icon
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 10)  {
                Text(viewModel.content)
                    .font(Font.custom("Inter-Regular", size: 16))
                    .foregroundColor(Color(hex: "#999999"))
                Text(viewModel.description)
                    .font(Font.custom("Inter-Medium", size: 14))
                    .foregroundColor(Color(hex: "#1C1C1C"))
            }
            Spacer()
        }
    }
}


struct PaymentsTaxesInfoCellView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsTaxesInfoCellView(viewModel: PaymentsTaxesInfoCellView.ViewModel(icon: Image("qr_Icon"), content: "Title", description: "SubTitle", action: {_ in }))
            .previewLayout(.fixed(width: 375, height: 56))
    }
}
