//
//  PaymentsSuccessOptionHeaderViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 04.03.2022.
//

import SwiftUI

//MARK: - View

extension PaymentsSuccessOptionHeaderView {
    
    struct ViewModel {
        
        let stateIcon: Image
        let title: String
        let description: String
        let operatorIcon: Image
        
        internal init(stateIcon: Image, title: String, description: String, operatorIcon: Image) {
            self.stateIcon = stateIcon
            self.title = title
            self.description = description
            self.operatorIcon = operatorIcon
        }
    }
}

struct PaymentsSuccessOptionHeaderView: View {
    
    let viewModel: PaymentsSuccessOptionHeaderView.ViewModel
    
    var body: some View {
        
        VStack(alignment:.center, spacing: 0) {
            
            viewModel.stateIcon
                .frame(width: 88, height: 88)
                .padding()
            Text(viewModel.title)
                .font(Font.custom("Inter-SemiBold", size: 18))
                .foregroundColor(Color(hex: "#1C1C1C"))
            Text(viewModel.description)
                .font(Font.custom("Inter-SemiBold", size: 24))
                .foregroundColor(Color(hex: "#1C1C1C"))
                .padding()
            viewModel.operatorIcon
                .frame(width: 32, height: 32)
                .padding()
        }
    }
}

//MARK: - Preview

struct PaymentsSuccessOptionHeaderView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentsSuccessOptionHeaderView(viewModel:
                                                .init(stateIcon: Image("OkOperators"),
                                                      title: "Успешный перевод",
                                                      description: "1 000,00 ₽",
                                                      operatorIcon: Image("Payments Service Sample")))
            .previewLayout(.fixed(width: 375, height: 300))
    }
}
