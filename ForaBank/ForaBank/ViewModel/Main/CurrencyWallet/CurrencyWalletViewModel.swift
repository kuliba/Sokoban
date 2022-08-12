//
//  CurrencyWalletViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 05.07.2022.
//

import SwiftUI
import Combine

protocol CurrencyWalletItem {
    
    var id: String { get }
}

// MARK: - ViewModel

class CurrencyWalletViewModel: ObservableObject {
    
    @Published var items: [CurrencyWalletItem]
    @Published var state: ButtonActionState
    @Published var currency: Currency
    @Published var currencyItem: CurrencyItemViewModel
    @Published var currencyOperation: CurrencyOperation
    @Published var currencySymbol: String
    @Published var buttonStyle: ButtonSimpleView.ViewModel.ButtonStyle
    @Published var selectorViewModel: CurrencySelectorView.ViewModel?
    @Published var confirmationViewModel: CurrencyExchangeConfirmationView.ViewModel?
    @Published var successViewModel: CurrencyExchangeSuccessView.ViewModel?
    @Published var selectorState: CurrencySelectorView.ViewModel.State
    @Published var isUserInteractionEnabled: Bool
    @Published var isShouldScrollToTop: Bool
    @Published var alert: Alert.ViewModel?
    
    private lazy var listViewModel: CurrencyListView.ViewModel = makeCurrencyList()
    private lazy var swapViewModel: CurrencySwapView.ViewModel = makeCurrencySwap()
    lazy var continueButton: ButtonSimpleView.ViewModel = makeContinueButton()
    
    private let model: Model
    private let closeAction: () -> Void
    
    let backButton: NavigationButtonViewModel
    let title = "Обмен валют"
    let icon: Image = .init("Logo Fora Bank")
    
    var verticalPadding: CGFloat {
        
        let safeAreaBottom = UIApplication.safeAreaInsets.bottom
        
        if safeAreaBottom == 34 {
            return 20
        }
        
        return safeAreaBottom
    }
    
    private var bindings = Set<AnyCancellable>()
    
    private var productType: ProductType? {
        
        var productId: ProductData.ID?
        
        if let selectorViewModel = selectorViewModel,
           let productCardSelector = selectorViewModel.productCardSelector,
           let productAccountSelector = selectorViewModel.productAccountSelector {
            
            switch currencyOperation {
            case .buy:
                productId = productAccountSelector.productViewModel.productId
            case .sell:
                productId = productCardSelector.productViewModel.productId
            }
        }
        
        guard let productId = productId,
              let productData = model.product(productId: productId) else {
            return nil
        }
        
        return productData.productType
    }
    
    enum ButtonActionState {
        
        case button
        case spinner
    }
    
    init(_ model: Model, currency: Currency, currencyItem: CurrencyItemViewModel, currencyOperation: CurrencyOperation, currencySymbol: String, items: [CurrencyWalletItem], state: ButtonActionState, action: @escaping () -> Void) {
        
        self.model = model
        self.closeAction = action
        self.currency = currency
        self.currencyItem = currencyItem
        self.currencyOperation = currencyOperation
        self.currencySymbol = currencySymbol
        self.items = items
        self.state = state
        
        backButton = .init(icon: .ic24ChevronLeft, action: action)
        buttonStyle = .red
        selectorState = .productSelector
        isUserInteractionEnabled = true
        isShouldScrollToTop = false
    }
    
    convenience init(_ model: Model, currency: Currency, currencyItem: CurrencyItemViewModel, currencyOperation: CurrencyOperation, currencySymbol: String, state: ButtonActionState = .button, action: @escaping () -> Void) {
        
        self.init(model, currency: currency, currencyItem: currencyItem, currencyOperation: currencyOperation, currencySymbol: currencySymbol, items: .init(), state: state, action: action)
        
        bind()
    }
    
    private func bind() {
       
        items = [listViewModel, swapViewModel]
        
        model.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case let payload as ModelAction.CurrencyWallet.ExchangeOperations.Start.Response:
                    
                    handleExchangeStartResponse(payload)
                    swapViewModel.swapButton.isUserInteractionEnabled = true
                    
                case let payload as ModelAction.CurrencyWallet.ExchangeOperations.Approve.Response:
                    handleExchangeApproveResponse(payload)
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        model.products
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] products in
                
                if selectorState == .openAccount {
                    
                    let products = products.values.flatMap {$0}.filter { $0.currency == currency.description }
                    
                    if products.isEmpty == false {
                        selectorViewModel = makeSelectorViewModel()
                    }
                }
                
            }.store(in: &bindings)
        
        listViewModel.$currency
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currency in
                
                self.currency = currency
                swapViewModel.currency = currency
                
                if let selectorViewModel = selectorViewModel {
                    selectorViewModel.currency = currency
                }
                
                setCurrencySymbol(currency)
                setProductSelectorData(currency)
                
            }.store(in: &bindings)
        
        $buttonStyle
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] buttonStyle in
                
                continueButton.style = buttonStyle
                
            }.store(in: &bindings)
        
        swapViewModel.$currencyOperation
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] currencyOperation in
                
                self.currencyOperation = currencyOperation
                
                if let selectorViewModel = selectorViewModel {
                    withAnimation {
                        selectorViewModel.currencyOperation = currencyOperation
                    }
                }
            }.store(in: &bindings)
        
        swapViewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as CurrencySwapAction.Button.Reset:
                    resetToInitial()
                    
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        $isUserInteractionEnabled
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] isEnabled in
                
                listViewModel.isUserInteractionEnabled = isEnabled
                swapViewModel.isUserInteractionEnabled = isEnabled
                selectorViewModel?.isUserInteractionEnabled = isEnabled
                
            }.store(in: &bindings)
    }
    
    private func makeCurrencyList() -> CurrencyListView.ViewModel {
        .init(model, currency: currency)
    }
    
    private func makeCurrencySwap() -> CurrencySwapView.ViewModel {
        
        let currencyRate = currencyOperation == .buy ? currencyItem.rateBuy : currencyItem.rateSell
        let currencyAmount = NumberFormatter.decimal(currencyRate) ?? 0
        let image = model.images.value[currencyItem.iconId]?.image
        
        return .init(
            model,
            currencySwap: .init(
                icon: image,
                currencyAmount: 1.00,
                currency: currency),
            сurrencyCurrentSwap: .init(
                icon: .init("Flag RUB"),
                currencyAmount: currencyAmount,
                currency: Currency(description: "RUB")),
            currencyOperation: currencyOperation,
            currency: currency,
            currencyRate: currencyAmount,
            quotesInfo: "1\(currencySymbol) = \(currencyRate) ₽")
    }
    
    private func makeContinueButton() -> ButtonSimpleView.ViewModel {
        
        .init(title: "Продолжить", style: buttonStyle) { [weak self] in
            
            guard let self = self else { return }
            self.continueButtonAction()
        }
    }
    
    private func resetToInitial() {
        
        withAnimation {
        
            items = items.compactMap { currencyItem in
                
                if currencyItem is CurrencyListView.ViewModel ||
                    currencyItem is CurrencySwapView.ViewModel {
                    
                    return currencyItem
                }
                
                return nil
            }
        }

        selectorViewModel = nil
        confirmationViewModel = nil
        successViewModel = nil
        
        buttonStyle = .red
        continueButton = makeContinueButton()
        
        isUserInteractionEnabled = true
    }
    
    private func makeSelectorViewModel() -> CurrencySelectorView.ViewModel {
        
        let products = model.products(currency: currency, currencyOperation: currencyOperation).sorted { $0.productType.order < $1.productType.order }
        
        buttonStyle = products.isEmpty == false ? .red : .inactive
        selectorState = products.isEmpty == false ? .productSelector : .openAccount
        
        let productSelectorViewModel = CurrencySelectorView.ViewModel(model, state: selectorState, currency: currency, currencyOperation: currencyOperation)
        
        if let productCardSelector = productSelectorViewModel.productCardSelector {
            
            productCardSelector.productViewModel.$isCollapsed
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isCollapsed in
                    
                    isShouldScrollToTop = isCollapsed == false
                    
                }.store(in: &bindings)
        }
        
        if let productAccountSelector = productSelectorViewModel.productAccountSelector {
            
            if let productId = model.product(currency: currency) {
                productAccountSelector.setProductSelectorData(productId: productId)
            }
            
            productAccountSelector.productViewModel.$isCollapsed
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isCollapsed in
                    
                    isShouldScrollToTop = isCollapsed == false
                    
                }.store(in: &bindings)
        }
        
        return productSelectorViewModel
    }
    
    private func makeConfirmationViewModel(data: CurrencyExchangeConfirmationData) {
        
        if confirmationViewModel == nil {
            
            confirmationViewModel = .init(response: data, model: model)
            
            if let confirmationViewModel = confirmationViewModel {
                
                withAnimation {
                    items.append(confirmationViewModel)
                }
            }
        }
    }
    
    private func continueButtonAction() {
        
        if selectorViewModel == nil {
            
            isShouldScrollToTop = true
            appendSelectorViewIfNeeds()
            
        } else {
            
            if confirmationViewModel == nil {
                
                state = .spinner
                isUserInteractionEnabled = false
                sendExchangeStartRequest()

            } else {
                
                if successViewModel == nil {
                
                    state = .spinner
                    sendExchangeApproveRequest()
                    
                } else {
                    
                    closeAction()
                }
            }
        }
    }
    
    private func setCurrencySymbol(_ currency: Currency) {
        
        let currencyList = model.currencyList.value
        let currencyData = currencyList.first(where: { $0.code == currency.description })
        
        guard let currencyData = currencyData,
              let currencySymbol = currencyData.currencySymbol else {
            return
        }
        
        self.currencySymbol = currencySymbol
    }
    
    private func appendSelectorViewIfNeeds() {
        
        model.action.send(ModelAction.Products.Update.Fast.All())
        selectorViewModel = makeSelectorViewModel()
        
        guard let selectorViewModel = self.selectorViewModel else {
            return
        }
        
        withAnimation {
            items.append(selectorViewModel)
        }
    }
    
    private func setProductSelectorData(_ currency: Currency) {
        
        if let selectorViewModel = selectorViewModel,
           let productAccountSelector = selectorViewModel.productAccountSelector {
            
            if let productId = model.product(currency: currency) {
                productAccountSelector.setProductSelectorData(productId: productId)
            }
        }
    }
    
    private func sendExchangeStartRequest() {
        
        if let selectorViewModel = selectorViewModel,
           let productCardSelector = selectorViewModel.productCardSelector,
           let productAccountSelector = selectorViewModel.productAccountSelector {
            
            switch currencyOperation {
            case .buy:
                
                model.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Start.Request(
                    amount: swapViewModel.сurrencyCurrentSwap.currencyAmount,
                    currency: swapViewModel.сurrencyCurrentSwap.currency.description,
                    productFrom: productCardSelector.productViewModel.productId,
                    productTo: productAccountSelector.productViewModel.productId))
                
            case .sell:
                
                model.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Start.Request(
                    amount: swapViewModel.currencySwap.currencyAmount,
                    currency: swapViewModel.currencySwap.currency.description,
                    productFrom: productAccountSelector.productViewModel.productId,
                    productTo: productCardSelector.productViewModel.productId))
            }
        }
    }
    
    private func sendExchangeApproveRequest() {
        model.action.send(ModelAction.CurrencyWallet.ExchangeOperations.Approve.Request())
    }
    
    private func handleExchangeStartResponse(_ payload: ModelAction.CurrencyWallet.ExchangeOperations.Start.Response) {
        
        switch payload.result {
        case let .success(response):
            
            state = .button
            makeConfirmationViewModel(data: response)
            
            if let productType = productType, let creditAmount = response.creditAmount, let currencyPayee = response.currencyPayee {
                
                let title = NumberFormatter.decimal(creditAmount)
                continueButton.title = "Купить \(title) \(currencyPayee.description)"
                
                model.action.send(ModelAction.Products.Update.ForProductType(productType: productType))
            }
            
        case let .failure(error):
            makeAlert(error: error)
        }
    }
    
    private func handleExchangeApproveResponse(_ payload: ModelAction.CurrencyWallet.ExchangeOperations.Approve.Response) {
        
        switch payload {
        case .successed:
            
            guard let confirmationViewModel = confirmationViewModel else {
                return
            }
            
            state = .button
            continueButton.title = "На главную"
            makeSuccessViewModel(confirmationViewModel.debitAmount, currency: confirmationViewModel.currencyPayer)
            
            model.action.send(ModelAction.Products.Update.Total.All())
            
        case let .failed(error):
            makeAlert(error: error)
        }
    }
    
    private func makeAlert(error: ModelCurrencyWalletError) {

        var messageError: String?
        
        switch error {
        case .emptyData(let message):
            messageError = message
        case .statusError(_, let message):
            messageError = message
        case let .serverCommandError(error):
            messageError = error.localizedDescription
        case let .cacheError(error):
            messageError = error.localizedDescription
        }

        guard let messageError = messageError else {
            return
        }

        alert = .init(
            title: "Ошибка",
            message: messageError,
            primary: .init(type: .default, title: "Ok") { [weak self] in
                
                guard let self = self else { return }
                self.state = .button
                self.alert = nil
            })
    }
    
    private func makeSuccessViewModel(_ amount: Double, currency: Currency) {
        
        successViewModel = .init(
            state: .success,
            amount: amount,
            currency: currency,
            delay: 2,
            model: model)
        
        if let successViewModel = successViewModel {
            
            withAnimation {
                items.append(successViewModel)
            }
        }
    }
    
    func resetCurrencySwap() {
        
        let currencySwap = swapViewModel.currencySwap
        let сurrencyCurrentSwap = swapViewModel.сurrencyCurrentSwap
        
        if currencySwap.textField.isEditing == true {
            currencySwap.action.send(CurrencySwapAction.TextField.Update(currencyAmount: currencySwap.currencyAmount))
        } else {
            сurrencyCurrentSwap.action.send(CurrencySwapAction.TextField.Update(currencyAmount: сurrencyCurrentSwap.currencyAmount))
        }
    }
}

extension CurrencyWalletViewModel {
    
    struct NavigationButtonViewModel: Identifiable {
        
        let id = UUID()
        let icon: Image
        let action: () -> Void
    }
}
