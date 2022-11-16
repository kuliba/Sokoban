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
        
        ZStack {
            
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
            
            if viewModel.state == .loading {
                
                Color.mainColorsBlack
                    .opacity(0.2)
                    .padding(.top, -29)
            }
        }
        .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in

            switch bottomSheet.type {
            case let .info(viewModel):
                InfoView(viewModel: viewModel)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .alert(item: $viewModel.alert) { alert in
            Alert(with: alert)
        }
    }
}

// MARK: - Previews

struct PaymentsMeToMeView_Previews: PreviewProvider {

    static var previews: some View {

        Group {

            PaymentsMeToMeView(viewModel: .init(
                .emptyMock,
                swapViewModel: .init(
                    model: .emptyMock,
                    items: [.sample1, .sample2],
                    divider: .sample),
                paymentsAmount: .init(
                    title: "Сумма перевода",
                    amount: 150,
                    transferButton: .active(title: "Перевести") {},
                    info: .button(title: "Без комиссии", icon: .ic16Info, action: {})), title: "Между своими"))
            
            PaymentsMeToMeView(viewModel: .init(
                .emptyMock,
                swapViewModel: .init(
                    model: .emptyMock,
                    items: [.sample1, .sample3],
                    divider: .sample),
                paymentsAmount: .init(
                    title: "Сумма перевода",
                    amount: 0,
                    transferButton: .active(title: "Перевести") {},
                    info: .button(title: "Без комиссии", icon: .ic16Info, action: {})), title: "Между своими"))
        }
        .previewLayout(.sizeThatFits)
        .padding(.top)
    }
}
