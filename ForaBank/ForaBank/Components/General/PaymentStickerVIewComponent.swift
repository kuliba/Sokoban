//
//  PaymentStickerVIewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 26.09.2023.
//

import Foundation
struct PaymentStickerView: View {
     
    let viewModel: PaymentStickerView.ViewModel
    
    var body: some View {
        
        ZStack {

            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)

            VStack(alignment: .leading) {

                OpenAccountItemView.HeaderView(viewModel: viewModel.header)

                HStack(alignment: .top, spacing: 20) {

                    OpenAccountCardView(viewModel: .sample)

                    VStack {

                        ForEach(viewModel.options) { option in
                            OpenAccountItemView.OptionView(viewModel: option)
                        }
                    }
                }.padding(20)

                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 200)
    }
}

