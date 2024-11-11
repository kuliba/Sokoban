//
//  PaymentsMeToMeView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 26.09.2022.
//

import SwiftUI

// MARK: - ViewFactory

struct PaymentsMeToMeViewFactory {
    
    let makeProductsSwapView: MakeProductsSwapView
}

// MARK: - View

struct PaymentsMeToMeView: View {
    
    @ObservedObject var viewModel: PaymentsMeToMeViewModel
    let viewFactory: PaymentsMeToMeViewFactory
    
    var body: some View {
        
        ZStack {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    
                    Text(viewModel.title)
                        .font(.textH3Sb18240())
                        .foregroundColor(.mainColorsBlack)
                        .accessibilityIdentifier("BtwTheirTitle")
                    
                    Spacer()
                    
                    switch viewModel.mode {
                    case .templatePayment:
                        Button(action: { viewModel.action.send(PaymentsMeToMeAction.Show.ChangeName()) }) {
                            
                            Image.ic24Edit2
                                .foregroundColor(.iconBlack)
                        }
                        
                    default:
                        EmptyView()
                            .frame(width: 0, height: 0)
                    }
                }.padding(.horizontal, 20)
                
                VStack {
                    
                    viewFactory.makeProductsSwapView(viewModel.swapViewModel)
                        .padding(.vertical, 20)
                    
                    PaymentsAmountView(viewModel: viewModel.paymentsAmount)
                }
            }
            
            if viewModel.state == .loading {
                
                Color.mainColorsBlack
                    .opacity(0.2)
                    .padding(.top, -29)
            }
        }
        .sheet(item: $viewModel.sheet, content: { sheet in
            switch sheet.type {
            case let .placesMap(placesViewModel):
                PlacesView(viewModel: placesViewModel)
            }
        })
        .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in

            switch bottomSheet.type {
            case let .info(viewModel):
                InfoView(viewModel: viewModel)
            case let .rename(viewModel):
                TemplatesListView.RenameTemplateItemView(viewModel: viewModel)
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

    private static func preview(
        _ viewModel: PaymentsMeToMeViewModel
    ) -> some View {
        PaymentsMeToMeView(viewModel: viewModel, viewFactory: .init(makeProductsSwapView: {_ in fatalError()}))
    }

    static var previews: some View {

        Group {
            
            preview(.init(
                .emptyMock,
                swapViewModel: .init(
                    model: .emptyMock,
                    items: [.sample2, .sampleMe2MeCollapsed],
                    divider: .sample),
                paymentsAmount: .init(
                    .emptyMock,
                    title: "Сумма перевода",
                    textField: .init(150, currencySymbol: "₽"),
                    transferButton: .active(title: "Перевести", action: {}),
                    info: .button(title: "Без комиссии", icon: .ic16Info, action: {})), title: "Между своими"))
            
            preview(.init(
                .emptyMock,
                swapViewModel: .init(
                    model: .emptyMock,
                    items: [.sampleMe2MeCollapsed, .sample2],
                    divider: .sample),
                paymentsAmount: .init(
                    .emptyMock,
                    title: "Сумма перевода",
                    textField: .init(150, currencySymbol: "₽"),
                    transferButton: .active(title: "Перевести", action: {}),
                    info: .button(title: "Без комиссии", icon: .ic16Info, action: {})), title: "Между своими"))
            
            preview(.init(
                .emptyMock,
                swapViewModel: .init(
                    model: .emptyMock,
                    items: [.sampleMe2MeCollapsed, .sample3],
                    divider: .sample),
                paymentsAmount: .init(
                    .emptyMock,
                    title: "Сумма перевода",
                    textField: .init(0, currencySymbol: "₽"),
                    transferButton: .active(title: "Перевести", action: {}),
                    info: .button(title: "Без комиссии", icon: .ic16Info, action: {})), title: "Между своими"))
        }
        .previewLayout(.sizeThatFits)
        .padding(.top)
    }
}
