//
//  CurrencySwapViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 24.06.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension CurrencySwapView {

    class ViewModel: ObservableObject {

        @Published var isSwapCurrency: Bool = false

        let action: PassthroughSubject<Action, Never> = .init()

        let quotesInfo: String
        let haveCurrencySwap: CurrencyViewModel
        let getCurrencySwap: CurrencyViewModel

        private var bindings = Set<AnyCancellable>()

        lazy var swapButton: SwapButtonViewModel = .init { [unowned self] in
            action.send(CurrencySwapAction.Button.Tapped())
        }

        init(quotesInfo: String, haveCurrencySwap: CurrencyViewModel, getCurrencySwap: CurrencyViewModel) {

            self.quotesInfo = quotesInfo
            self.haveCurrencySwap = haveCurrencySwap
            self.getCurrencySwap = getCurrencySwap

            bind()
        }

        private func bind() {

            action
                .receive(on: DispatchQueue.main)
                .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
                .sink { action in

                    switch action {
                    case _ as CurrencySwapAction.Button.Tapped:

                        if #available(iOS 14.0, *) {

                            withAnimation {
                                self.isSwapCurrency.toggle()
                            }
                        } else {

                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.isSwapCurrency.toggle()
                            }
                        }
                    default:
                        break
                    }
                }.store(in: &bindings)
        }
    }
}

extension CurrencySwapView.ViewModel {

    // MARK: - Swap

    class CurrencyViewModel: ObservableObject {
        
        @Published var currencyAmount: Double

        let icon: Image
        let title: String
        let currencyType: String
        
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
                doneButton: .init(isEnabled: true) {
                    UIApplication.shared.endEditing()
                }, closeButton: nil))

        init(icon: Image, title: String, currencyAmount: Double, currencyType: String) {

            self.icon = icon
            self.title = title
            self.currencyAmount = currencyAmount
            self.currencyType = currencyType
        }
    }

    // MARK: - Button

    struct SwapButtonViewModel {

        let icon: Image = .init("Swap")
        let action: () -> Void
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

                if viewModel.isSwapCurrency == true {

                    if #available(iOS 14.0, *) {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.haveCurrencySwap)
                            .matchedGeometryEffect(id: "haveCurrency", in: namespace)
                    } else {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.haveCurrencySwap)
                            .transition(bottomTransition)
                    }

                } else {

                    if #available(iOS 14.0, *) {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.getCurrencySwap)
                            .matchedGeometryEffect(id: "getCurrency", in: namespace)
                    } else {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.getCurrencySwap)
                            .transition(bottomTransition)
                    }
                }

                HStack(spacing: 20) {

                    Divider()
                        .frame(width: 244, height: 1)
                        .background(Color.mainColorsGrayMedium)

                    SwapButtonView(viewModel: viewModel.swapButton)
                }

                if viewModel.isSwapCurrency == true {

                    if #available(iOS 14.0, *) {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.getCurrencySwap)
                            .matchedGeometryEffect(id: "getCurrency", in: namespace)
                    } else {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.getCurrencySwap)
                            .transition(topTransition)
                    }

                } else {

                    if #available(iOS 14.0, *) {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.haveCurrencySwap)
                            .matchedGeometryEffect(id: "haveCurrency", in: namespace)
                    } else {

                        CurrencySwapView.CurrencyView(viewModel: viewModel.haveCurrencySwap)
                            .transition(topTransition)
                    }
                }
            }

            VStack(spacing: 0) {

                Spacer()

                HStack(spacing: 0) {

                    Spacer()

                    Text(viewModel.quotesInfo)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)
                }
            }.padding(20)

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

            HStack(spacing: 16) {

                viewModel.icon
                    .resizable()
                    .frame(width: 32, height: 32)

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
            }
        }
    }

    // MARK: - Button

    struct SwapButtonView: View {

        let viewModel: ViewModel.SwapButtonViewModel

        var body: some View {

            Button(action: viewModel.action) {

                viewModel.icon
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Action

enum CurrencySwapAction {

    enum Button {

        struct Tapped: Action {}
        struct Done: Action {}
        struct Close: Action {}
    }
}

// MARK: - Preview Content

extension CurrencySwapView.ViewModel {

    static let sample: CurrencySwapView.ViewModel = .init(
        quotesInfo: "1$ = 64.50 ₽",
        haveCurrencySwap: .init(
            icon: .init("Flag RUB"),
            title: "У меня есть",
            currencyAmount: 64.50,
            currencyType: "RUB"),
        getCurrencySwap: .init(
            icon: .init("Flag USD"),
            title: "Я получу",
            currencyAmount: 1.00,
            currencyType: "USD"))
}

// MARK: - Previews

struct CurrencySwapVIewComponent_Previews: PreviewProvider {
    static var previews: some View {

        VStack {
            CurrencySwapView(viewModel: .sample)
        }.previewLayout(.sizeThatFits)
    }
}
