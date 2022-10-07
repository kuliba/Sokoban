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
        
        @Published var title: String
        @Published var currencySymbol: String
        @Published var openAccountIcon: Image
        @Published var currency: Currency
        @Published var currencyName: String
        @Published var isUserInteractionEnabled: Bool
        
        lazy var warning: WarningViewModel = makeWarning()
        var bindings = Set<AnyCancellable>()
        
        private let model: Model
        
        var openTitle: String {
            "Открыть \(currency.description) счет"
        }
        
        let cardIcon: Image = .init("Accounts")
        
        init(model: Model,
             title: String,
             currencySymbol: String = "",
             openAccountIcon: Image = Image("Plus Account"),
             currencyName: String = "Валютный",
             isUserInteractionEnabled: Bool = true,
             currency: Currency) {
            
            self.model = model
            self.title = title
            self.currencySymbol = currencySymbol
            self.openAccountIcon = openAccountIcon
            self.currency = currency
            self.currencyName = currencyName
            self.isUserInteractionEnabled = isUserInteractionEnabled
            
            bind()
        }
        
        private func bind() {
            
            $currency
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currency in
                    
                    warning.description = warningTitle(currency)
                    
                    if let currencyData = model.dictionaryCurrency(for: currency.description),
                       let currencySymbol = currencyData.currencySymbol {
                        self.currencySymbol = currencySymbol
                    }
                    
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
        .background(Color.mainColorsGrayLightest)
        .disabled(viewModel.isUserInteractionEnabled == false)
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
                    
                    if viewModel.currencySymbol.isEmpty == false {
                        
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 3)
                                .foregroundColor(.cardAccount)
                                .frame(width: 32, height: 22)
                            
                            Text(viewModel.currencySymbol)
                                .foregroundColor(.mainColorsWhite)
                                .fixedSize(horizontal: true, vertical: true)
                            
                        }.padding(.top, 2)
                        
                    } else {
                        
                        viewModel.cardIcon
                            .resizable()
                            .frame(width: 32, height: 32)
                            .offset(y: -3)
                    }
                    
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
            
            HStack(alignment: .top, spacing: 20) {
                
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
    
    static let sample: CurrencyWalletAccountView.ViewModel = .init(model: .productsMock, title: "Откуда", currencySymbol: "$", currency: .usd)
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
