//
//  ProductAccountViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 13.07.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension CurrencyWalletAccountView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var cardIcon: Image
        @Published var openAccountIcon: Image
        @Published var currency: Currency
        @Published var currencyName: String
        @Published var warning: WarningViewModel
        @Published var bottomSheet: BottomSheet?
        
        var bindings = Set<AnyCancellable>()
        
        private let model: Model
        let title: String
        
        var currencyTitle: String {
            "Открыть \(currency.description) счет"
        }
        
        struct BottomSheet: Identifiable {
            
            let id = UUID()
            let type: SheetType
            
            enum SheetType {
                case openAccount(OpenAccountViewModel)
            }
        }
        
        init(model: Model,
             title: String = "Куда",
             cardIcon: Image,
             openAccountIcon: Image = Image("Plus Account"),
             currency: Currency,
             currencyName: String,
             warning: WarningViewModel) {
            
            self.model = model
            self.title = title
            self.cardIcon = cardIcon
            self.openAccountIcon = openAccountIcon
            self.currency = currency
            self.currencyName = currencyName
            self.warning = warning
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as CurrencyWalletAccountView.ProductAction.Toggle:
                        
                        let productsList = model.accountProductsList.value
                        
                        if productsList.isEmpty == false {
                            
                            let viewModel: OpenAccountViewModel = .init(model: model, items: OpenAccountViewModel.reduce(products: productsList))
                            
                            bottomSheet = .init(type: .openAccount(viewModel))
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

extension CurrencyWalletAccountView.ViewModel {
    
    // MARK: - Warning
    
    class WarningViewModel: ObservableObject {
        
        let icon: Image
        let description: String
        
        init(icon: Image = Image("Warning Account"), description: String) {
            
            self.icon = icon
            self.description = description
        }
    }
}

// MARK: - View

struct CurrencyWalletAccountView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            ProductView(viewModel: viewModel)
            WarningView(viewModel: viewModel.warning)
        }
        .bottomSheet(item: $viewModel.bottomSheet) { bottomSheet in
            switch bottomSheet.type {
            case let .openAccount(viewModel):
                OpenAccountView(viewModel: viewModel)
            }
        }
        .background(Color.mainColorsGrayLightest)
        .padding(.horizontal, 20)
    }
}

extension CurrencyWalletAccountView {
    
    // MARK: - ProductView
    
    struct ProductView: View {
        
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            
            Group {
                
                Text(viewModel.title)
                    .font(.textBodySR12160())
                    .foregroundColor(.textPlaceholder)
                
                HStack(alignment: .top, spacing: 16) {
                    
                    viewModel.cardIcon
                        .resizable()
                        .frame(width: 32, height: 32)
                        .offset(y: -3)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HStack(alignment: .center, spacing: 10) {
                            
                            Text(viewModel.currencyTitle)
                                .font(.textBodyMM14200())
                                .foregroundColor(.mainColorsBlack)
                            
                            Spacer()
                            
                            viewModel.openAccountIcon
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.mainColorsGray)
                        }
                        
                        Text(viewModel.currencyName)
                            .font(.textBodySR12160())
                            .foregroundColor(.mainColorsGray)
                    }
                }.onTapGesture {
                    
                    viewModel.action.send(CurrencyWalletAccountView.ProductAction.Toggle())
                }
            }
        }
    }
    
    // MARK: - Warning
    
    struct WarningView: View {
        
        @ObservedObject var viewModel: ViewModel.WarningViewModel
        
        var body: some View {
            
            HStack(spacing: 20) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 4)
                
                Text(viewModel.description)
                    .font(.textBodySR12160())
                    .foregroundColor(.mainColorsGray)
            }
        }
    }
}

extension CurrencyWalletAccountView {
    
    enum ProductAction {
    
        struct Toggle: Action {}
    }
}

// MARK: - Preview Content

extension CurrencyWalletAccountView.ViewModel {
    
    static let sample = CurrencyWalletAccountView.ViewModel(
        model: .productsMock,
        cardIcon: Image("USD Account"),
        currency: Currency(description: "USD"),
        currencyName: "Валютный",
        warning: .init(description: "Для завершения операции Вам необходимо открыть счет в долларах США"))
}

// MARK: - Previews

struct ProductAccountViewComponent_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            CurrencyWalletAccountView(viewModel: .sample)
                .padding()
        }
        .background(Color.mainColorsGrayLightest)
        .previewLayout(.sizeThatFits)
    }
}
