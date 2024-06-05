//
//  CurrencySwapViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 24.06.2022.
//

import SwiftUI
import Combine
import Shimmer

typealias CurrencyOperation = CurrencySwapView.ViewModel.CurrencyOperation

// MARK: - ViewModel

extension CurrencySwapView {

    class ViewModel: ObservableObject, CurrencyWalletItem {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var currencyOperation: CurrencyOperation
        @Published var currency: Currency
        @Published var currencyRate: Double
        @Published var quotesInfo: String
        @Published var isUserInteractionEnabled: Bool

        let model: Model
        let id = UUID().uuidString
        
        /// Иностранная валюта
        let currencySwap: CurrencyViewModel
        
        /// Российская валюта
        let сurrencyCurrentSwap: CurrencyViewModel
        
        /// Переключатель валют
        lazy var switchViewModel: CurrencySwitchViewModel = .init(currencyOperation: currencyOperation, swapButton: swapButton)

        lazy var swapButton: SwapButtonViewModel = .init(icon: .init("Swap")) { [unowned self] in
            
            switch swapButton.state {
            case .normal:
                action.send(CurrencySwapAction.Button.Tapped())
            case .reset:
                action.send(CurrencySwapAction.Button.Reset())
            }
        }
        
        private var bindings = Set<AnyCancellable>()

        init(_ model: Model, currencySwap: CurrencyViewModel, сurrencyCurrentSwap: CurrencyViewModel, currencyOperation: CurrencyOperation, currency: Currency, currencyRate: Double, quotesInfo: String, isUserInteractionEnabled: Bool = true) {

            self.model = model
            self.currencySwap = currencySwap
            self.сurrencyCurrentSwap = сurrencyCurrentSwap
            self.currencyOperation = currencyOperation
            self.currency = currency
            self.currencyRate = currencyRate
            self.quotesInfo = quotesInfo
            self.isUserInteractionEnabled = isUserInteractionEnabled

            bind()
        }
        
        enum CurrencyOperation {
            
            case buy
            case sell
        }

        private func bind() {
            
            model.currencyWalletList
                .combineLatest(model.currencyList, model.images)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
                    
                    let currencyWalletList = data.0
                    let currencyList = data.1
                    let images = data.2
                    
                    let currencyData = currencyList.first(where: { $0.code == currency.description })
                    
                    update(currencyWalletList, currencyData: currencyData)
                    updateIcon(currencyWalletList, images: images)
                    
                }.store(in: &bindings)

            action
                .receive(on: DispatchQueue.main)
                .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
                .sink { [unowned self] action in

                    switch action {
                    case _ as CurrencySwapAction.Button.Tapped:
                        
                        withAnimation {
                            toggleCurrencyType()
                        }
                        
                        let currencyWalletList = model.currencyWalletList.value
                        let currencyData = model.currencyList.value.first(where: { $0.code == currency.description })
                        
                        update(currencyWalletList, currencyData: currencyData)
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        model.action.send(ModelAction.Account.ProductList.Request())
                        
                    case _ as CurrencySwapAction.Button.Reset:
                        swapButton.state = .normal
                        
                    default:
                        break
                    }
                }.store(in: &bindings)
            
            $currencyOperation
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currencyOperation in

                    titleSwap(currencyOperation)
                    switchViewModel.currencyOperation = currencyOperation
                    
                }.store(in: &bindings)
            
            $currency
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currencyType in
                    
                    let currencyWalletList = model.currencyWalletList.value
                    let currencyList = model.currencyList.value
                    let images = model.images.value
                    
                    let currencyData = currencyList.first(where: { $0.code == currency.description })
                    
                    update(currencyWalletList, currencyData: currencyData)
                    updateIcon(currencyWalletList, images: images)
                    
                }.store(in: &bindings)
            
            currencySwap.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as CurrencySwapAction.TextField.Update:
                        
                        let currencyAmount = payload.currencyAmount
                        updateCurrencyAction(currencyAmount)
                        
                    case let payload as CurrencySwapAction.TextField.Done:
                        
                        сurrencyCurrentSwap.lastCurrencyAmount = 0
                        updateCurrencyAction(payload.currencyAmount)
                        
                    default:
                        break
                    }
                }.store(in: &bindings)
            
            сurrencyCurrentSwap.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as CurrencySwapAction.TextField.Update:
                        
                        let currencyAmount = payload.currencyAmount
                        updateCurrencyCurrentAction(currencyAmount)
                        
                    case let payload as CurrencySwapAction.TextField.Done:
                        
                        currencySwap.lastCurrencyAmount = 0
                        updateCurrencyCurrentAction(payload.currencyAmount)
                        
                    default:
                        break
                    }
                }.store(in: &bindings)

            currencySwap.textField.$text
                .combineLatest(currencySwap.textField.$isEditing)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
                    
                    let text = data.0
                    let isEditing = data.1
                    
                    guard let text = text,
                          let value = NumberFormatter.decimal(text),
                          isEditing == true else {
                        return
                    }
                    
                    let isEquality = currencyEquality(lhs: currencySwap.currencyAmount, rhs: value)
                    
                    
                    if isEquality == false {
                        
                        let currentValue = value * currencyRate
                        сurrencyCurrentSwap.currencyAmount = currencyOperation == .buy ? currentValue.roundUp() : currentValue.roundDown()
                        
                    } else {
                        
                        if сurrencyCurrentSwap.lastCurrencyAmount == 0 {
                            
                            let currentValue = value * currencyRate
                            сurrencyCurrentSwap.currencyAmount = currencyOperation == .buy ? currentValue.roundUp() : currentValue.roundDown()
                            
                        } else {
                            сurrencyCurrentSwap.currencyAmount = сurrencyCurrentSwap.lastCurrencyAmount
                            
                        }
                    }
                    
                    сurrencyCurrentSwap.textField.isEditing = false
                    
                }.store(in: &bindings)
            
            сurrencyCurrentSwap.textField.$text
                .combineLatest(сurrencyCurrentSwap.textField.$isEditing)
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] data in
                    
                    let text = data.0
                    let isEditing = data.1
                    
                    guard let text = text,
                          let value = NumberFormatter.decimal(text),
                          isEditing == true else {
                        return
                    }
                    
                    switch currencyOperation {
                    case .buy:
                       
                        currencySwap.currencyAmount = (value / currencyRate).roundDown()
              
                    case .sell:
                        
                        currencySwap.currencyAmount = (value / currencyRate).roundUp()
                
                    }
                    
                    currencySwap.textField.isEditing = false
                    
                }.store(in: &bindings)
            
            $isUserInteractionEnabled
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEnabled in
                
                    currencySwap.isUserInteractionEnabled = isEnabled
                    сurrencyCurrentSwap.isUserInteractionEnabled = isEnabled
                    swapButton.isUserInteractionEnabled = isEnabled
                    
                    if isEnabled == true {
                        swapButton.state = .normal
                    }
                
                }.store(in: &bindings)
        }
        
        private func currencyEquality (lhs: Double, rhs: Double) -> Bool {
            
            let value = NumberFormatter.decimal(lhs)
            let lhs = NumberFormatter.decimal(value)
            
            return lhs == rhs
        }
        
        private func toggleCurrencyType() {
            
            currencyOperation = currencyOperation == .buy ? .sell : .buy
        }
        
        private func titleSwap(_ currencyOperation: CurrencyOperation) {
            
            withAnimation(.easeInOut) {
                
                currencySwap.title = currencyOperation == .buy ? "Я получу" : "У меня есть"
                сurrencyCurrentSwap.title = currencyOperation == .buy ? "У меня есть" : "Я получу"
            }
        }
        
    }
}

// MARK: - Update

extension CurrencySwapView.ViewModel {
    
    private func updateCurrencyAction(_ currencyAmount: Double) {
        
        currencySwap.currencyAmount = currencyAmount
        
        switch currencyOperation {
        case .buy:
            
            if сurrencyCurrentSwap.lastCurrencyAmount == 0 {
                сurrencyCurrentSwap.currencyAmount = (currencyAmount * currencyRate).roundUp()
                
            } else {
                
                if сurrencyCurrentSwap.lastCurrencyAmount == 0 && currencySwap.lastCurrencyAmount == 0 {
                    сurrencyCurrentSwap.currencyAmount = (currencyAmount * currencyRate).roundUp()
                    
                } else {
                    сurrencyCurrentSwap.currencyAmount = сurrencyCurrentSwap.lastCurrencyAmount
                }
            }
            
        case .sell:
            
            if сurrencyCurrentSwap.lastCurrencyAmount == 0 {
                сurrencyCurrentSwap.currencyAmount = (currencyAmount * currencyRate).roundDown()
                
            } else {
                сurrencyCurrentSwap.currencyAmount = сurrencyCurrentSwap.lastCurrencyAmount
            }
        }
    }
    
    private func updateCurrencyCurrentAction(_ currencyAmount: Double) {
        
        сurrencyCurrentSwap.currencyAmount = currencyAmount
     
        switch currencyOperation {
        case .buy:
           
            currencySwap.currencyAmount = (currencyAmount / currencyRate).roundDown()
            
        case .sell:
            
            currencySwap.currencyAmount = (currencyAmount / currencyRate).roundUp()
       
        }
    }
    
    private func updateCurrencyAmoun(_ currencyAmount: Double) {
        
        switch currencyOperation {
        case .buy:
            
            currencySwap.currencyAmount = (сurrencyCurrentSwap.currencyAmount / currencyAmount).roundDown()
            
            if сurrencyCurrentSwap.lastCurrencyAmount > 0 {
                сurrencyCurrentSwap.currencyAmount = сurrencyCurrentSwap.lastCurrencyAmount
            }
            
        case .sell:
            currencySwap.currencyAmount = (сurrencyCurrentSwap.currencyAmount / currencyAmount).roundUp()
        }
    }
    
    private func updateCurrencyCurrentAmount(_ currencyAmount: Double) {
        
        if сurrencyCurrentSwap.lastCurrencyAmount == 0 {
            
            let newAmount = currencySwap.currencyAmount * currencyAmount
            сurrencyCurrentSwap.currencyAmount = currencyOperation == .buy ? newAmount.roundUp() : newAmount.roundDown()
           
        } else {
            
            сurrencyCurrentSwap.currencyAmount = сurrencyCurrentSwap.lastCurrencyAmount
            
            let newAmount = сurrencyCurrentSwap.currencyAmount / currencyRate
            currencySwap.currencyAmount = currencyOperation == .buy ? newAmount.roundUp() : newAmount.roundDown()
          
        }
    }
    
    private func update(_ currencyWalletList: [CurrencyWalletData], currencyData: CurrencyData?) {
        
        let itemData = currencyWalletList.first(where: { $0.code == currency.description })
        
        guard let currencyData = currencyData,
              let currencySymbol = currencyData.currencySymbol,
              let itemData = itemData
        else { return }
     
        let currencyRateOperation = currencyOperation == .buy ? itemData.rateSell : itemData.rateBuy
        let currencyMultiplierRate = currencyRateOperation * Double(itemData.currAmount)
        let currencyAmount = currencyRateOperation
        
        self.currencyRate = currencyRateOperation
        self.quotesInfo = "\(itemData.currAmount)\(currencySymbol) = \(NumberFormatter.decimal(currencyMultiplierRate)) ₽"
        
        if сurrencyCurrentSwap.lastCurrencyAmount == 0 && currencySwap.lastCurrencyAmount == 0 {
            
            updateCurrencyCurrentAmount(currencyAmount)
            
        } else {
            
            if currencyOperation == .buy {
                
                if сurrencyCurrentSwap.lastCurrencyAmount == 0 {
                    
                    updateCurrencyCurrentAmount(currencyAmount)

                } else {
                   
                    updateCurrencyAmoun(currencyAmount)
                }
                
            } else {
                
                if currencySwap.lastCurrencyAmount == 0 {
                    
                    updateCurrencyAmoun(currencyAmount)
                    
                } else {
                    
                    updateCurrencyCurrentAmount(currencyAmount)
                }
            }
        }
    }
    
    private func updateIcon(_ currencyWalletList: [CurrencyWalletData], images: [String: ImageData]) {
        
        let items = CurrencyListViewModel.reduceCurrencyWallet(currencyWalletList, images: images, currency: currency)
        let item = items.first(where: { $0.currency.description == currency.description })
        
        guard let item = item else {
            return
        }
        
        guard let image = images[item.iconId]?.image else {
            
            model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [item.iconId]))
            return
        }
        
        currencySwap.icon = image
        currencySwap.currency = currency
    }
}

extension CurrencySwapView.ViewModel {

    // MARK: - Swap

    class CurrencyViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var currencyAmount: Double
        @Published var lastCurrencyAmount: Double
        @Published var title: String
        @Published var currency: Currency
        @Published var icon: Image?
        @Published var isUserInteractionEnabled: Bool

        private var bindings = Set<AnyCancellable>()
        
        var font: UIFont {
            
            guard let font = UIFont(name: "Inter-Medium", size: 16) else {
                return .systemFont(ofSize: 16)
            }
            
            return font
        }
        
        lazy var textField: TextFieldFormatableView.ViewModel = .init(
            type: .currency,
            value: currencyAmount,
            formatter: .decimal(),
            isEnabled: true,
            limit: 9,
            toolbar: .init(doneButton: .init(isEnabled: true) { [weak self] in
                
                guard let self = self,
                      let text = self.textField.text,
                      let value = NumberFormatter.decimal(text) else {
                    return
                }
                
                self.currencyAmount = value
                self.lastCurrencyAmount = value
                
                self.action.send(CurrencySwapAction.TextField.Done(currencyAmount: self.currencyAmount))
                UIApplication.shared.endEditing()
                
            }))

        init(icon: Image?, currencyAmount: Double, title: String = "", currency: Currency, isUserInteractionEnabled: Bool = true) {

            self.icon = icon
            self.currencyAmount = currencyAmount
            self.currency = currency
            self.title = title
            self.isUserInteractionEnabled = isUserInteractionEnabled
            
            lastCurrencyAmount = 0
            
            bind()
        }
        
        private func bind() {
            
            $currencyAmount
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currencyAmount in
                    
                    textField.text = NumberFormatter.decimal(currencyAmount)
                    
                }.store(in: &bindings)
        }
    }
    
    // MARK: - Switch
    
    class CurrencySwitchViewModel: ObservableObject {
        
        @Published var currencyOperation: CurrencyOperation
        @Published var pathInset: Double
        
        let swapButton: SwapButtonViewModel
        private var bindings = Set<AnyCancellable>()
        
        init(currencyOperation: CurrencyOperation, swapButton: SwapButtonViewModel, pathInset: Double = 5) {
            
            self.currencyOperation = currencyOperation
            self.swapButton = swapButton
            self.pathInset = pathInset
            
            bind()
        }
        
        private func bind() {
            
            $currencyOperation
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currencyOperation in
                    
                    withAnimation(.easeInOut) {
                        swapButton.isCurrencySwap.toggle()
                    }
                }.store(in: &bindings)
        }
    }

    // MARK: - Button

    class SwapButtonViewModel: ObservableObject {
        
        @Published var isCurrencySwap: Bool
        @Published var isUserInteractionEnabled: Bool
        @Published var icon: Image
        @Published var state: State

        let action: () -> Void
        
        private var bindings = Set<AnyCancellable>()
        
        var rotationAngle: Angle {
            isCurrencySwap ? .degrees(0) : .degrees(180)
        }
        
        enum State {
            
            case normal
            case reset
        }
        
        init(isCurrencySwap: Bool = false, isUserInteractionEnabled: Bool = true, icon: Image, action: @escaping () -> Void) {
            
            self.isCurrencySwap = isCurrencySwap
            self.isUserInteractionEnabled = isUserInteractionEnabled
            self.icon = icon
            self.action = action
            
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
                        icon = .init("Swap")
                    }
                    
                }.store(in: &bindings)
        }
    }
}

// MARK: - View

struct CurrencySwapView: View {

    @Namespace private var namespace
    @ObservedObject var viewModel: ViewModel

    var topTransition: AnyTransition {
        .asymmetric(insertion: .move(edge: .top), removal: .identity)
    }

    var bottomTransition: AnyTransition {
        .asymmetric(insertion: .move(edge: .bottom), removal: .identity)
    }

    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)

            HStack {
                
                VStack(alignment: .leading, spacing: 4) {
                        
                        if viewModel.currencyOperation == .buy {
                            
                            CurrencySwapView.CurrencyView(viewModel: viewModel.сurrencyCurrentSwap)
                                .matchedGeometryEffect(id: "getCurrency", in: namespace)
                            
                        } else {
                            
                            CurrencySwapView.CurrencyView(viewModel: viewModel.currencySwap)
                                .matchedGeometryEffect(id: "haveCurrency", in: namespace)
                        }
                        
                        CurrencySwitchView(viewModel: viewModel.switchViewModel)
                        
                        if viewModel.currencyOperation == .buy {
                            
                            CurrencySwapView.CurrencyView(viewModel: viewModel.currencySwap)
                                .matchedGeometryEffect(id: "haveCurrency", in: namespace)
                            
                        } else {
                            
                            CurrencySwapView.CurrencyView(viewModel: viewModel.сurrencyCurrentSwap)
                                .matchedGeometryEffect(id: "getCurrency", in: namespace)
                        }
                        
                }.padding(.vertical, 20)
            }
            
            VStack {

                Spacer()

                HStack {

                    Spacer()

                    Text(viewModel.quotesInfo)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
        }
        .frame(height: 160)
        .padding(.horizontal, 20)
    }
}

extension CurrencySwapView {

    // MARK: - Swap

    struct CurrencyView: View {

        @ObservedObject var viewModel: ViewModel.CurrencyViewModel

        var body: some View {

            HStack(alignment: .center, spacing: 16) {

                if let icon = viewModel.icon {
                    
                    icon
                        .resizable()
                        .frame(width: 32, height: 32)
                } else {
                 
                    Circle()
                        .fill(Color.mainColorsGrayMedium)
                        .frame(width: 32, height: 32)
                        .shimmering()
                }

                VStack(alignment: .leading, spacing: 4) {

                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)

                    HStack(alignment: .bottom, spacing: 4) {

                        TextFieldFormatableView(
                            viewModel: viewModel.textField,
                            font: viewModel.font,
                            textColor: .mainColorsBlack,
                            tintColor: .mainColorsBlack,
                            keyboardType: .decimalPad)
                        .fixedSize(horizontal: true, vertical: false)

                        Text(viewModel.currency.description)
                            .font(.textH4M16240())
                            .foregroundColor(.mainColorsGrayMedium)
                        
                    }.onTapGesture {
                        viewModel.textField.becomeFirstResponder()
                    }
                }
            }
            .disabled(viewModel.isUserInteractionEnabled == false)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Switch
    
    struct CurrencySwitchView: View {
        
        @ObservedObject var viewModel: ViewModel.CurrencySwitchViewModel
  
        var body: some View {
            
            GeometryReader { proxy in
                
                HStack(spacing: 20) {
                    
                    Path { path in
                        
                        let height = proxy.size.height / 2
                        
                        path.move(to: .init(x: 0, y: height))
                        path.addLine(to: .init(x: 10, y: height))
                        path.addLine(to: .init(x: 16, y: height + viewModel.pathInset))
                        path.addLine(to: .init(x: 22, y: height))
                        path.addLine(to: .init(x: proxy.size.width - 92, y: height))
                    }
                    .stroke()
                    .foregroundColor(.mainColorsGrayMedium)
                    
                    CurrencySwapView.SwapButtonView(viewModel: viewModel.swapButton)
                    
                }.padding(.horizontal, 20)
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
            .buttonStyle(CurrencySwapView.SwapButtonStyle())
            .disabled(viewModel.isUserInteractionEnabled == false)
        }
    }
    
    struct SwapButtonStyle: ButtonStyle {
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(Color.mainColorsGrayLightest)
        }
    }
}

// MARK: - Action

enum CurrencySwapAction {
    
    enum Button {
        
        struct Tapped: Action {}
        struct Reset: Action {}
        struct Close: Action {}
    }
    
    enum TextField {
        
        struct Update: Action {
            
            let currencyAmount: Double
        }
        
        struct Done: Action {
            
            let currencyAmount: Double
        }
    }
}

// MARK: - Preview Content

extension CurrencySwapView.ViewModel {
    
    static let sample: CurrencySwapView.ViewModel = .init(
        .emptyMock,
        currencySwap: .init(
            icon: .init("Flag USD"),
            currencyAmount: 1.00,
            currency: Currency(description: "USD")),
        сurrencyCurrentSwap: .init(
            icon: .init("Flag RUB"),
            currencyAmount: 64.50,
            currency: Currency(description: "RUB")),
        currencyOperation: .buy,
        currency: Currency(description: "USD"),
        currencyRate: 64.50,
        quotesInfo: "1$ = 64.50 ₽")
    
    static let sample100: CurrencySwapView.ViewModel = .init(
        .emptyMock,
        currencySwap: .init(
            icon: .init("Flag USD"),
            currencyAmount: 1.00,
            currency: Currency(description: "USD")),
        сurrencyCurrentSwap: .init(
            icon: .init("Flag RUB"),
            currencyAmount: 0.16,
            currency: Currency(description: "RUB")),
        currencyOperation: .buy,
        currency: Currency(description: "USD"),
        currencyRate: 0.1599,
        quotesInfo: "100$ = 15.99 ₽")
}

// MARK: - Previews

struct CurrencySwapVIewComponent_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            CurrencySwapView(viewModel: .sample)
            CurrencySwapView(viewModel: .sample100)
        }
        .previewLayout(.sizeThatFits)
        .padding(.vertical)
    }
}
