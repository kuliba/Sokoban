//
//  PaymentsMeToMeView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

import SwiftUI

// MARK: - View

struct PaymentsMeToMeView: View {
    
    @ObservedObject var viewModel: PaymentsMeToMeViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(viewModel.title)
                .font(.textH3SB18240())
                .foregroundColor(.mainColorsBlack)
                .padding(.horizontal, 20)
            
            VStack {
                
                ProductsSwapView(viewModel: viewModel.swapViewModel)
                PaymentsAmountView(viewModel: viewModel.paymentsAmount)
            }
        }
    }
}

// MARK: - Previews

struct PaymentsMeToMeView_Previews: PreviewProvider {

    static var previews: some View {

        Group {

            PaymentsMeToMeView(viewModel: .init(
                .emptyMock,
                mode: .general,
                swapViewModel: .init(
                    model: .emptyMock,
                    items: [.sample1, .sample2]),
                paymentsAmount: .init(
                    title: "Сумма перевода",
                    amount: 150,
                    transferButton: .active(title: "Перевести") {},
                    info: .button(title: "Без комиссии", icon: .ic16Info, action: {})),
                closeAction: {}))
            
            PaymentsMeToMeView(viewModel: .init(
                .emptyMock,
                mode: .general,
                swapViewModel: .init(
                    model: .emptyMock,
                    items: [.sample1, .sample3]),
                paymentsAmount: .init(
                    title: "Сумма перевода",
                    amount: 0,
                    transferButton: .active(title: "Перевести") {},
                    info: .button(title: "Без комиссии", icon: .ic16Info, action: {})),
                closeAction: {}))
        }
        .previewLayout(.sizeThatFits)
        .padding(.top)
    }
}
