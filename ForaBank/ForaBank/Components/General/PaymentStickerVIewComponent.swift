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

// MARK: - Previews

struct PaymentStickerView_Previews: PreviewProvider {

    static var previews: some View {
        
        Group {
            
            PaymentStickerView(viewModel: .init(
                header: .init(
                    title: "Платежный стикер",
                    detailTitle: "Стоимость обслуживания взимается единоразово за весь срок при заказе стикера"
                ),
                card: .init(viewModel: .sample),
                options: [.init(
                    title: "При получении в офисе",
                    icon: .checkImage,
                    description: "700",
                    colorType: .green
                )]
            ))
            .previewLayout(.sizeThatFits)
            .padding(8)
            
        }
    }
}
