//
//  ProductsSwapView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 22.09.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension ProductsSwapView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var items: [ProductSelectorView.ViewModel]
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        let divider: DividerViewModel
        
        var from: ProductSelectorView.ViewModel? { items.first }
        var to: ProductSelectorView.ViewModel? { items.last }
        
        var productIdFrom: ProductData.ID? {
            
            guard let from = from, let productViewModel = from.productViewModel else {
                return nil
            }
            
            return productViewModel.id
        }
        
        var productIdTo: ProductData.ID? {
            
            guard let to = to, let productViewModel = to.productViewModel else {
                return nil
            }
            
            return productViewModel.id
        }
        
        init(model: Model, items: [ProductSelectorView.ViewModel], divider: DividerViewModel) {
            
            self.model = model
            self.items = items
            self.divider = divider
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductsSwapView.ViewModel initialized")
        }
        
        deinit {
            
            LoggerAgent.shared.log(level: .debug, category: .ui, message: "ProductsSwapView.ViewModel deinitialized")
        }
        
        convenience init?(_ model: Model, mode: PaymentsMeToMeViewModel.Mode) {
            
            switch mode {
            case .demandDeposit:
                
                let productFromFilter = ProductData.Filter(
                    rules: [ProductData.Filter.DebitRule(),
                            ProductData.Filter.ProductTypeRule([.card, .account, .deposit]),
                            ProductData.Filter.DemandDepositRule(),
                            ProductData.Filter.CardActiveRule(),
                            ProductData.Filter.CardCorporateIsIndividualBusinessmanMainRule(),
                            ProductData.Filter.CardAdditionalSelfRule(),
                            ProductData.Filter.AccountActiveRule()])
                guard let productDataFrom = model.firstProduct(with: productFromFilter) else {
                    return nil
                }

                let productToFilter = ProductData.Filter(
                    rules: [ProductData.Filter.CreditRule(),
                            ProductData.Filter.ProductTypeRule([.card, .account, .deposit]),
                            ProductData.Filter.CardActiveRule(),
                            ProductData.Filter.CardCorporateIsIndividualBusinessmanMainRule(),
                            ProductData.Filter.CardAdditionalSelfRule(),
                            ProductData.Filter.AccountActiveRule()])

                let contextFrom = ProductSelectorView.ViewModel.Context(title: "Откуда", direction: .from, style: .me2me, filter: productFromFilter)
                let contextTo = ProductSelectorView.ViewModel.Context(title: "Куда", direction: .to, style: .me2me, filter: productToFilter)
                
                let from = ProductSelectorView.ViewModel(model, productData: productDataFrom, context: contextFrom)
                let to = ProductSelectorView.ViewModel(model, context: contextTo)
                
                self.init(model: model, items: [from, to], divider: .init())
                
                setupSwapButton()

            case .general:
                
                let productFromFilter: ProductData.Filter = .meToMeFrom
                guard let productDataFrom = model.firstProduct(with: productFromFilter) else {
                    return nil
                }
                
                let contextFrom = ProductSelectorView.ViewModel.Context(title: "Откуда", direction: .from, style: .me2me, filter: productFromFilter)
                let contextTo = ProductSelectorView.ViewModel.Context(title: "Куда", direction: .to, style: .me2me, filter: .meToMeTo)
                
                let from = ProductSelectorView.ViewModel(model, productData: productDataFrom, context: contextFrom)
                let to = ProductSelectorView.ViewModel(model, context: contextTo)
                
                self.init(model: model, items: [from, to], divider: .init())
                
                setupSwapButton()
                
            case let .closeAccount(productData, _):
                
                let contextFrom = ProductSelectorView.ViewModel.Context(title: "Откуда", direction: .from, style: .me2me, isUserInteractionEnabled: false, filter: .closeAccountFrom)
                
                var filterTo = ProductData.Filter.closeAccountTo
                
                // check if product currency is not rub
                if productData.currencyValue != .rub {
     
                    // allowed only product currency and rub
                    filterTo.rules.append(ProductData.Filter.CurrencyRule([productData.currencyValue, .rub]))
                }
            
                filterTo.rules.append(ProductData.Filter.ProductRestrictedRule([productData.id]))
                let contextTo = ProductSelectorView.ViewModel.Context(title: "Куда", direction: .to, style: .me2me, filter: filterTo)
                
                let from = ProductSelectorView.ViewModel(model, productData: productData, context: contextFrom)
                let to = ProductSelectorView.ViewModel(model, context: contextTo)
                
                self.init(model: model, items: [from, to], divider: .init())
                
            case let .closeDeposit(productData, _):
                
                let contextFrom = ProductSelectorView.ViewModel.Context(title: "Откуда", direction: .from, style: .me2me, isUserInteractionEnabled: false, filter: .closeDepositFrom)
                
                var filterTo = ProductData.Filter.closeDepositTo
                filterTo.rules.append(ProductData.Filter.CurrencyRule([.init(description: productData.currency)]))
                filterTo.rules.append(ProductData.Filter.ProductRestrictedRule([productData.id]))
                let contextTo = ProductSelectorView.ViewModel.Context(title: "Куда", direction: .to, style: .me2me, filter: filterTo)
                
                let from = ProductSelectorView.ViewModel(model, productData: productData, context: contextFrom)
                let to = ProductSelectorView.ViewModel(model, context: contextTo)
                
                self.init(model: model, items: [from, to], divider: .init())
                
            case let .makePaymentTo(productToData, _):
                var filterFrom = ProductData.Filter.generalFrom
                /*
                 temp off because of case with the single account product. Additional analytics is required.
                 
                filterFrom.rules.append(ProductData.Filter.ProductRestrictedRule([productToData.id]))
                 */
                
                guard let productFromData = model.firstProduct(with: filterFrom) else {
                    return nil
                }
                
                let contextFrom = ProductSelectorView.ViewModel.Context(title: "Откуда", direction: .from, style: .me2me, filter: filterFrom)
                
                let filterTo = ProductData.Filter.generalToWithDeposit
                
                let contextTo = ProductSelectorView.ViewModel.Context(title: "Куда", direction: .to, style: .me2me, filter: filterTo)

                let from = ProductSelectorView.ViewModel(model, productData: productFromData, context: contextFrom)
                let to = ProductSelectorView.ViewModel(model, productData: productToData, context: contextTo)
                
                self.init(model: model, items: [from, to], divider: .init())
                    
            case let .templatePayment(templateId, _):
                
                guard let (productTo, productFrom, _) = model.productsTransfer(templateId: templateId) else {
                    return nil
                }
                
                let filterFrom = ProductData.Filter.generalFrom
                    
                let contextFrom = ProductSelectorView.ViewModel.Context(title: "Откуда",
                                                                        direction: .from,
                                                                        style: .me2me,
                                                                        filter: filterFrom)
                let filterTo = ProductData.Filter.generalToWithDeposit

                let contextTo = ProductSelectorView.ViewModel.Context(title: "Куда",
                                                                      direction: .to,
                                                                      style: .me2me,
                                                                      filter: filterTo)

                let from = ProductSelectorView.ViewModel(model,
                                                         productData: productFrom,
                                                         context: contextFrom)
                let to = ProductSelectorView.ViewModel(model,
                                                       productData: productTo,
                                                       context: contextTo)
                    
                self.init(model: model,
                          items: [from, to],
                          divider: .init())
                setupSwapButton()
                    
            case let .makePaymentToDeposite(productToData, _):
                var filterFrom = ProductData.Filter(
                    rules: [ProductData.Filter.DebitRule(),
                            ProductData.Filter.ProductTypeRule([.card, .account, .deposit]),
                            ProductData.Filter.CardActiveRule(),
                            ProductData.Filter.CardAdditionalSelfRule(),
                            ProductData.Filter.AccountActiveRule()])
                filterFrom.rules.append(ProductData.Filter.ProductRestrictedRule([productToData.id]))
                
                let filterTo = ProductData.Filter(
                    rules: [ProductData.Filter.CreditRule(),
                            ProductData.Filter.ProductTypeRule([.card, .account, .deposit]),
                            ProductData.Filter.CardActiveRule(),
                            ProductData.Filter.CardAdditionalSelfRule(),
                            ProductData.Filter.AccountActiveRule()])
                let contextFrom = ProductSelectorView.ViewModel.Context(title: "Откуда", direction: .from, style: .me2me, filter: filterFrom)
                let contextTo = ProductSelectorView.ViewModel.Context(title: "Куда", direction: .to, style: .me2me, isUserInteractionEnabled: true, filter: filterTo)

                let from = ProductSelectorView.ViewModel(model, context: contextFrom)
                let to = ProductSelectorView.ViewModel(model, productData: productToData, context: contextTo)
                
                self.init(model: model, items: [from, to], divider: .init())
                
            case let .transferDeposit(productData, _), let .transferAndCloseDeposit(productData, _):
                
                let contextFrom = ProductSelectorView.ViewModel.Context(title: "Откуда", direction: .from, style: .me2me, isUserInteractionEnabled: false, filter: .closeDepositFrom)
                
                var filterTo = ProductData.Filter.closeDepositTo
                filterTo.rules.append(ProductData.Filter.ProductRestrictedRule([productData.id]))
                let contextTo = ProductSelectorView.ViewModel.Context(title: "Куда", direction: .to, style: .me2me, filter: filterTo)
                
                let from = ProductSelectorView.ViewModel(model, productData: productData, context: contextFrom)
                let to = ProductSelectorView.ViewModel(model, context: contextTo)
                
                self.init(model: model, items: [from, to], divider: .init())

            }
            
            bind()
            bind(items: items)
        }
        
        private func bind() {
            
            action
                .compactMap { $0 as? ProductsSwapAction.Button.Tap }
                .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    swapItems()
                }
                .store(in: &bindings)
         }
        
        private func swapItems() {
            
            withAnimation {
                
                items = items.reversed()
                
                guard
                    let from = from,
                    let to = to
                else {
                    return
                }
                
                let contextFrom = from.context.value
                let contextTo = to.context.value
                
                self.from?.context.value = contextTo
                self.to?.context.value = contextFrom
                
                divider.isToogleButton.toggle()
                self.action.send(ProductsSwapAction.Swapped())
            }
        }
        
        func bind(items: [ProductSelectorView.ViewModel]) {
            
            for item in items {
                
                item.action
                    .compactMap { $0 as? ProductSelectorAction.Selected }
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] payload in
                        
                        if let from = from, item.id == from.id {
                            self.action.send(ProductsSwapAction.Selected.From(productId: payload.id))
                        } else {
                            self.action.send(ProductsSwapAction.Selected.To(productId: payload.id))
                        }
                    }
                    .store(in: &bindings)
                
                item.action
                    .compactMap { $0 as? ProductSelectorAction.Product.Tap }
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] payload in
                        
                        guard let from = from, let to = to else {
                            return
                        }
                        
                        if from.id == payload.id {
                            to.collapseList()
                        } else {
                            from.collapseList()
                        }
                        
                        UIApplication.shared.hideKeyboardIfNeeds()
                    }
                    .store(in: &bindings)
            }
        }
        
        private func setupSwapButton() {
            
            divider.swapButton = .init() { [weak self] in
                
                guard let self = self else { return }
                
                if let swapButton = self.divider.swapButton {
                    
                    switch swapButton.state {
                    case .normal:
                        self.action.send(ProductsSwapAction.Button.Tap())
                    case .reset:
                        self.action.send(ProductsSwapAction.Button.Reset())
                    }
                }
            }
        }
    }
}

extension ProductsSwapView.ViewModel {
    
    // MARK: - Divider
    
    class DividerViewModel: ObservableObject {
        
        @Published var isToogleButton: Bool
        @Published var pathInset: Double
        
        let id: UUID = .init()
        var swapButton: SwapButtonViewModel?
        private var bindings = Set<AnyCancellable>()
        
        init(isToogleButton: Bool = false, swapButton: SwapButtonViewModel? = nil, pathInset: Double = 5) {
            
            self.isToogleButton = isToogleButton
            self.swapButton = swapButton
            self.pathInset = pathInset
            
            bind()
        }
        
        private func bind() {
            
            $isToogleButton
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isToogleButton in
                    
                    if let swapButton = swapButton {
                        
                        withAnimation {
                            swapButton.isSwap = isToogleButton
                        }
                    }

                }.store(in: &bindings)
        }
    }
    
    // MARK: - Button

    class SwapButtonViewModel: ObservableObject {
        
        @Published var isSwap: Bool
        @Published var isUserInteractionEnabled: Bool
        @Published var icon: Image
        @Published var state: State
        @Published var isSwapButtonEnabled: Bool


        let action: () -> Void
        
        private var bindings = Set<AnyCancellable>()
        
        var rotationAngle: Angle {
            isSwap ? .degrees(0) : .degrees(180)
        }
        
        enum State {
            
            case normal
            case reset
        }
        
        init(isSwap: Bool = false, isUserInteractionEnabled: Bool = true, icon: Image = .ic32Swap, isSwapButtonEnabled: Bool = true, action: @escaping () -> Void) {
            
            self.isSwap = isSwap
            self.isUserInteractionEnabled = isUserInteractionEnabled
            self.icon = icon
            self.action = action
            self.isSwapButtonEnabled = isSwapButtonEnabled
            state = .normal
            
            bind()
        }
        
        private func bind() {
            
            $isUserInteractionEnabled
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEnabled in
                    
                    if isEnabled == false {
                        
                        icon = .init("Swap Reset")
                        state = .reset
                    }
                    
                }.store(in: &bindings)
            
            $state
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] state in
                    
                    if state == .normal {
                        icon = .ic32Swap
                    }
                    
                }.store(in: &bindings)
        }
    }
}

// MARK: - View

struct ProductsSwapView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            ForEach(viewModel.items) { item in
                ProductSelectorView(viewModel: item)
                    .padding(.top, 4)
                
                if let from = viewModel.from, item.id == from.id {
                    DividerView(viewModel: viewModel.divider)
                        .padding(.horizontal, 20)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)        
    }
}

extension ProductsSwapView {
    
    // MARK: - Divider
    
    struct DividerView: View {
        
        @ObservedObject var viewModel: ViewModel.DividerViewModel
  
        var body: some View {
            
                HStack(spacing: 20) {
                    
                    GeometryReader { proxy in
                        
                        Path { path in
                            
                            let height = proxy.size.height / 2
                            
                            path.move(to: .init(x: 0, y: height))
                            path.addLine(to: .init(x: 10, y: height))
                            path.addLine(to: .init(x: 16, y: height + viewModel.pathInset))
                            path.addLine(to: .init(x: 22, y: height))
                            path.addLine(to: .init(x: proxy.size.width, y: height))
                        }
                        .stroke()
                        .foregroundColor(.mainColorsGrayMedium)
                    }
                    
                    if let swapButton = viewModel.swapButton {
                        ProductsSwapView.SwapButtonView(viewModel: swapButton)
                    }
                }
        }
    }
    
    // MARK: - Button

    struct SwapButtonView: View {

        @ObservedObject var viewModel: ViewModel.SwapButtonViewModel

        var body: some View {

            Button(action: viewModel.action) {

                viewModel.icon
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 32, height: 32)
                    .rotationEffect(viewModel.rotationAngle)
            }
            .buttonStyle(ProductsSwapView.SwapButtonStyle(isSwapButtonEnabled: viewModel.isSwapButtonEnabled))
            .disabled(!viewModel.isSwapButtonEnabled || !viewModel.isUserInteractionEnabled)
        }
    }
    
    struct SwapButtonStyle: ButtonStyle {
        let isSwapButtonEnabled: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(isSwapButtonEnabled ? .mainColorsGray : .buttonPrimaryDisabled)
        }
    }
}

// MARK: - Action

enum ProductsSwapAction {
    
    enum Button {
        
        struct Tap: Action {}
        struct Reset: Action {}
        struct Close: Action {}
    }
    
    struct Swapped: Action {}
    
    enum Selected {
        
        struct From: Action {
            
            let productId: ProductData.ID
        }
        
        struct To: Action {
            
            let productId: ProductData.ID
        }
    }
}


//MARK: - Preview Content

extension ProductsSwapView.ViewModel.DividerViewModel {
    
    static var sample: ProductsSwapView.ViewModel.DividerViewModel = .init(swapButton: .init(action: {}))
}

// MARK: - Previews

struct ProductsSwapViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            previewGroup()
                .previewLayout(.sizeThatFits)
            
            VStack(content: previewGroup)
                .previewLayout(.sizeThatFits)
        }
    }
    
    static func previewGroup() -> some View {
        
        Group {
            
            productsSwapView([.sample2, .sampleMe2MeCollapsed])
            productsSwapView([.sampleMe2MeCollapsed, .sample2])
            productsSwapView([.sampleMe2MeCollapsed, .sample3])
            productsSwapView([.sample3, .sampleMe2MeCollapsed])
        }
    }
    
    private static func productsSwapView(
        _ items: [ProductSelectorView.ViewModel]
    ) -> ProductsSwapView {
        
        ProductsSwapView(
            viewModel: .init(model: .emptyMock, items: items, divider: .sample)
        )
    }
}

extension Model {
    
    func productsTransfer(templateId: PaymentTemplateData.ID) -> (productTo: ProductData, productFrom: ProductData, amount: Double)? {
        
        guard let template = self.paymentTemplates.value.first(where: { $0.id == templateId }),
              let parameterList = template.parameterList as? [TransferGeneralData],
              let payeeProductId = parameterList.lastPayeeProductId,
              let productTo = self.product(productId: payeeProductId),
              let payerProductId = parameterList.last?.payer?.productIdDescription,
              let payerProductIdInt = Int(payerProductId),
              let productFrom = self.product(productId: payerProductIdInt) else {
            return nil
        }
        
        let amount = parameterList.last?.amountDouble ?? 0
        
        return (productTo: productTo, productFrom: productFrom, amount: amount)
    }
}
