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

    class ViewModel: ObservableObject {

        @Published var currencyOperation: CurrencyOperation
        @Published var currency: Currency
        @Published var currencyRate: Double

        let action: PassthroughSubject<Action, Never> = .init()

        let model: Model
        
        /// Иностранная валюта
        let currencySwap: CurrencyViewModel
        
        /// Российская валюта
        let сurrencyCurrentSwap: CurrencyViewModel

        private var bindings = Set<AnyCancellable>()

        lazy var swapButton: SwapButtonViewModel = .init { [unowned self] in
            action.send(CurrencySwapAction.Button.Tapped())
        }

        init(_ model: Model, currencySwap: CurrencyViewModel, сurrencyCurrentSwap: CurrencyViewModel, currencyOperation: CurrencyOperation, currency: Currency, currencyRate: Double) {

            self.model = model
            self.currencySwap = currencySwap
            self.сurrencyCurrentSwap = сurrencyCurrentSwap
            self.currencyOperation = currencyOperation
            self.currency = currency
            self.currencyRate = currencyRate

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
                    
                    update(currencyWalletList: currencyWalletList, currencyData: currencyData)
                    updateImage(currencyWalletList: currencyWalletList, images: images)
                    
                }.store(in: &bindings)

            action
                .receive(on: DispatchQueue.main)
                .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
                .sink { [unowned self] action in

                    switch action {
                    case _ as CurrencySwapAction.Button.Tapped:

                        if #available(iOS 14.0, *) {

                            withAnimation {
                                toggleCurrencyType()
                            }
                        } else {

                            withAnimation(.easeInOut(duration: 0.2)) {
                                toggleCurrencyType()
                            }
                        }
                        
                        let currencyWalletList = model.currencyWalletList.value
                        let currencyData = model.currencyList.value.first(where: { $0.code == currency.description })
                        
                        update(currencyWalletList: currencyWalletList, currencyData: currencyData)
                        
                        model.action.send(ModelAction.Dictionary.UpdateCache.List(types: [.currencyWalletList, .currencyList]))
                        
                    default:
                        break
                    }
                }.store(in: &bindings)
            
            $currencyOperation
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currencyOperation in

                    withAnimation(.easeInOut) {
                        
                        titleSwap(currencyOperation)
                        swapButton.isSwap.toggle()
                    }
                }.store(in: &bindings)
            
            $currency
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] currencyType in
                    
                    let currencyWalletList = model.currencyWalletList.value
                    let currencyList = model.currencyList.value
                    let images = model.images.value
                    
                    let currencyData = currencyList.first(where: { $0.code == currency.description })
                    
                    update(currencyWalletList: currencyWalletList, currencyData: currencyData)
                    updateImage(currencyWalletList: currencyWalletList, images: images)
                    
                }.store(in: &bindings)
            
            currencySwap.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as CurrencySwapAction.TextField.Done:
                        
                        сurrencyCurrentSwap.currencyAmount = payload.currencyAmount * currencyRate
                        
                    default:
                        break
                    }
                }.store(in: &bindings)
            
            сurrencyCurrentSwap.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as CurrencySwapAction.TextField.Done:
                        
                        currencySwap.currencyAmount = сurrencyCurrentSwap.currencyAmount / currencyRate
                        
                    default:
                        break
                    }
                }.store(in: &bindings)
        }
        
        private func update(currencyWalletList: [CurrencyWalletData], currencyData: CurrencyData?) {
            
            let items = Model.reduceCurrencyWallet(currencyWalletList, images: model.images.value, currencyType: currency.description)
            let item = items.first(where: { $0.currency.description == currency.description })
            
            guard let currencyData = currencyData,
                  let currencySymbol = currencyData.currencySymbol,
                  let item = item else {
                return
            }
         
            let currencyRateOperation = currencyOperation == .buy ? item.rateBuy : item.rateSell
            let currencyAmount = NumberFormatter.decimal(currencyRateOperation) ?? 0
            
            withAnimation(.interactiveSpring()) {
                
                currencyRate = currencyAmount
                сurrencyCurrentSwap.currencyAmount = currencySwap.currencyAmount * currencyAmount
                currencySwap.quotesInfo = "1\(currencySymbol) = \(currencyAmount) ₽"
            }
        }
        
        private func updateImage(currencyWalletList: [CurrencyWalletData], images: [String: ImageData]) {
            
            let items = Model.reduceCurrencyWallet(currencyWalletList, images: images, currencyType: currency.description)
            let item = items.first(where: { $0.currency.description == currency.description })
            
            guard let item = item else {
                return
            }
            
            guard let image = images[item.iconId]?.image else {
                
                model.action.send(ModelAction.Dictionary.DownloadImages.Request(imagesIds: [item.iconId]))
                return
            }
            
            withAnimation(.interactiveSpring()) {
                
                currencySwap.icon = image
                currencySwap.currencyType = currency.description
            }
        }
        
        private func toggleCurrencyType() {
            
            currencyOperation = currencyOperation == .buy ? .sell : .buy
        }
        
        private func titleSwap(_ currencyOperation: CurrencyOperation) {
            
            currencySwap.title = currencyOperation == .buy ? "Я получу" : "У меня есть"
            сurrencyCurrentSwap.title = currencyOperation == .buy ? "У меня есть" : "Я получу"
        }
    }
}

extension CurrencySwapView.ViewModel {

    // MARK: - Swap

    class CurrencyViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var currencyAmount: Double
        @Published var title: String
        @Published var currencyType: String
        @Published var icon: Image?
        @Published var quotesInfo: String?

        private var bindings = Set<AnyCancellable>()
        
        var font: UIFont {
            
            guard let font = UIFont(name: "Inter-Medium", size: 16) else {
                return .systemFont(ofSize: 16)
            }
            
            return font
        }
        
        lazy var textField: TextFieldFormatableView.ViewModel = .init(
            type: .currencyWallet,
            value: currencyAmount,
            formatter: .decimal(),
            isEnabled: true,
            limit: 10,
            toolbar: .init(
                doneButton: .init(isEnabled: true) { [weak self] in
                    
                    guard let self = self, let text = self.textField.text else {
                        return
                    }
                    
                    self.currencyAmount = NumberFormatter.decimal(text) ?? 0
                    UIApplication.shared.endEditing()
                    
                    self.action.send(CurrencySwapAction.TextField.Done(currencyAmount: self.currencyAmount))
                    
                }, closeButton: nil))

        init(icon: Image?, currencyAmount: Double, title: String = "", currencyType: String, quotesInfo: String? = nil) {

            self.icon = icon
            self.currencyAmount = currencyAmount
            self.currencyType = currencyType
            self.title = title
            self.quotesInfo = quotesInfo
            
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

    // MARK: - Button

    class SwapButtonViewModel: ObservableObject {
        
        @Published var isSwap: Bool

        let icon: Image
        let action: () -> Void
        
        init(isSwap: Bool = false, icon: Image = .init("Swap"), action: @escaping () -> Void) {
            
            self.isSwap = isSwap
            self.icon = icon
            self.action = action
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

            VStack(alignment: .leading, spacing: 4) {

                if viewModel.currencyOperation == .buy {

                    if #available(iOS 14.0, *) {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.сurrencyCurrentSwap)
                            .matchedGeometryEffect(id: "getCurrency", in: namespace)
                        
                    } else {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.сurrencyCurrentSwap)
                            .transition(bottomTransition)
                    }

                } else {
                    
                    if #available(iOS 14.0, *) {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.currencySwap)
                            .matchedGeometryEffect(id: "haveCurrency", in: namespace)
                        
                    } else {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.currencySwap)
                            .transition(bottomTransition)
                    }
                }

                HStack(spacing: 20) {

                    Divider()
                        .frame(width: 244, height: 1)
                        .background(Color.mainColorsGrayMedium)

                    SwapButtonView(viewModel: viewModel.swapButton)
                    
                }.padding(.horizontal, 20)

                if viewModel.currencyOperation == .buy {

                    if #available(iOS 14.0, *) {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.currencySwap)
                            .matchedGeometryEffect(id: "haveCurrency", in: namespace)
                        
                    } else {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.currencySwap)
                            .transition(topTransition)
                    }
                    
                } else {

                    if #available(iOS 14.0, *) {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.сurrencyCurrentSwap)
                            .matchedGeometryEffect(id: "getCurrency", in: namespace)
                        
                    } else {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.сurrencyCurrentSwap)
                            .transition(topTransition)
                    }
                }
            }
        }
        .frame(height: 160)
        .padding(20)
    }
}

extension CurrencySwapView {

    // MARK: - Swap

    struct CurrencyView: View {

        @ObservedObject var viewModel: ViewModel.CurrencyViewModel

        var body: some View {

            HStack(alignment: .bottom, spacing: 16) {

                if let icon = viewModel.icon {
                    
                    icon
                        .resizable()
                        .frame(width: 32, height: 32)
                } else {
                 
                    Circle()
                        .fill(Color.mainColorsGrayMedium)
                        .frame(width: 32, height: 32)
                        .shimmering(active: true, bounce: false)
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
                        .fixedSize()

                        Text(viewModel.currencyType)
                            .font(.textH4M16240())
                            .foregroundColor(.mainColorsGrayMedium)
                    }
                }
                
                if let quotesInfo = viewModel.quotesInfo {
                    
                    Spacer()
                    
                    Text(quotesInfo)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)
                }
                
            }.padding(.horizontal, 20)
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
                    .rotationEffect(viewModel.isSwap ? .degrees(0) : .degrees(180))
            }.buttonStyle(CurrencySwapView.SwapButtonStyle())
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
        struct Close: Action {}
    }
    
    enum TextField {
        
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
            currencyType: "USD",
            quotesInfo: "1$ = 64.50 ₽"),
        сurrencyCurrentSwap: .init(
            icon: .init("Flag RUB"),
            currencyAmount: 64.50,
            currencyType: "RUB"),
        currencyOperation: .buy,
        currency: Currency(description: "USD"),
        currencyRate: 64.50)
}

// MARK: - Previews

struct CurrencySwapVIewComponent_Previews: PreviewProvider {
    static var previews: some View {

        VStack {
            CurrencySwapView(viewModel: .sample)
        }.previewLayout(.sizeThatFits)
    }
}
