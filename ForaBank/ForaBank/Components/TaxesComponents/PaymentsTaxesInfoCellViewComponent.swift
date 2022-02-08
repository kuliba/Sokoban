//
//  CellViewType_1.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import SwiftUI

extension PaymentsTaxesInfoCellViewComponent {
    
    struct ViewModel {
    
        let icon: Image
        let content: String
        let description: String
    }
}

struct PaymentsTaxesInfoCellViewComponent: View {
    
    let viewModel: PaymentsTaxesInfoCellViewComponent.ViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            
            VStack(alignment: .leading, spacing: 10) {
                viewModel.icon
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.top, 20)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10)  {
                Text(viewModel.content)
                    .font(Font.custom("Inter-Regular", size: 16))
                    .foregroundColor(Color(hex: "#999999"))
                    .padding(.top, 8)
                Text(viewModel.description)
                    .font(Font.custom("Inter-Medium", size: 14))
                    .foregroundColor(Color(hex: "#1C1C1C"))
                Spacer()
            }
            Spacer()
        }
    }
}


struct PaymentsTaxesInfoCellViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsTaxesInfoCellViewComponent(viewModel: PaymentsTaxesInfoCellViewComponent.ViewModel(icon: Image("qr_Icon"), content: "content", description: "Налог на имущество физических лиц, взимаемый по ставкам, применяемым к объектам налогообложения, расположенным в границах внутригородских муниципальных образований городов федерального значения (сумма платеж...)"))
            .previewLayout(.fixed(width: 375, height: 156))
    }
}
