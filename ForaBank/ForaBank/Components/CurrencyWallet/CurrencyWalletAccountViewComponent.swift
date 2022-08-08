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
        @Published var bottomSheet: BottomSheet?
        
        lazy var warning: WarningViewModel = makeWarning()
        var bindings = Set<AnyCancellable>()
        
        private let model: Model
        let title: String
        
        var openTitle: String {
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
             cardIcon: Image = Image("USD Account"),
             openAccountIcon: Image = Image("Plus Account"),
             currencyName: String = "Валютный",
             currency: Currency) {
            
            self.model = model
            self.title = title
            self.cardIcon = cardIcon
            self.openAccountIcon = openAccountIcon
            self.currency = currency
            self.currencyName = currencyName
            
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
                            
                            let viewModel: OpenAccountViewModel = .init(model: model, items: OpenAccountViewModel.reduce(products: productsList), currency: currency)
                            
                            bottomSheet = .init(type: .openAccount(viewModel))
                        }
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            $currency
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currency in
                    
                    warning.description = warningTitle(currency)
                    
                }.store(in: &bindings)
        }
        
        private func warningTitle(_ currency: Currency) -> String {
            "Для завершения операции Вам необходимо открыть счет \(currency.currencyTitle)"
        }
        
        private func makeWarning() -> WarningViewModel {
            .init(icon: Image("Warning Account"), description: warningTitle(currency))
        }
    }
}

extension CurrencyWalletAccountView.ViewModel {
    
    // MARK: - Warning
    
    class WarningViewModel: ObservableObject {
        
        @Published var description: String
        let icon: Image
        
        init(icon: Image, description: String) {
            
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
                            
                            Text(viewModel.openTitle)
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
                    .frame(height: 48, alignment: .top)
                    .padding(.trailing)
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
    
    static let sample: CurrencyWalletAccountView.ViewModel = .init(model: .productsMock, currency: .usd)
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
