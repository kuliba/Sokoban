//
//  PaymentsAmountViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.02.2022.
//

import SwiftUI

extension PaymentsTaxesAmountView {
    
    class ViewModel: PaymentsParameterViewModel {
        @Published var context: String = ""
    }
}

struct PaymentsTaxesAmountView: View {
    
    @ObservedObject var viewModel: PaymentsTaxesAmountView.ViewModel
    
    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            Spacer()
            Text("Сумма перевода")
                .font(Font.custom("Inter-Regular", size: 12))
                .foregroundColor(Color(hex: "#999999"))
                .padding(.leading, 8)
            
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    VStack (alignment: .center) {
                        Spacer()
                        TextField("1000", text: $viewModel.context)
                            .foregroundColor(Color(hex: "#FFFFFF"))
                            .font(Font.custom("Inter-Regular", size: 16))
                        Divider()
                            .frame(height: 1)
                            .foregroundColor(Color(hex: "#EAEBEB"))
                    }
                    Button {

                    } label: {
                        Image("")
                            .frame(width: 24, height: 24, alignment: .center)
                    }
                    Button {

                    } label: {
                        Text("Перевести")
                            .font(Font.custom("Inter-Regular", size: 16))
                            .foregroundColor(Color(hex: "#FFFFFF"))
                            .frame(width: 114, height: 40, alignment: .center)
                    } .background(Color(hex: "#FF3636"))
                        .cornerRadius(8)

                }
            }
            HStack(alignment: .center) {
                Text("Размер комиссии")
                    .font(Font.custom("Inter-Regular", size: 12))
                    .foregroundColor(Color(hex: "#999999"))

                Button {

                } label: {
                    Image("infoBlack")
                        .frame(width: 8, height: 8)
                        .foregroundColor(Color(hex: "#999999"))
                } .padding(.leading, 8)
            } .padding(.leading, 8)
            
            Spacer()
        }.background(Color(hex: "#3D3D45"))
            
        
    }
}


struct PaymentsTaxesAmountViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsTaxesAmountView(viewModel: .init())
                .previewLayout(.fixed(width: 375, height: 88))
    }
    
}
