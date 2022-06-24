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
        let haveCurrencySwap: SwapViewModel
        let getCurrencySwap: SwapViewModel

        private var bindings = Set<AnyCancellable>()

        lazy var swapButton: SwapButtonViewModel = .init { [unowned self] in
            action.send(CurrencySwapAction.Button.Tapped())
        }

        var bottomTransition: AnyTransition {
            .asymmetric(insertion: .move(edge: .bottom), removal: .identity)
        }

        var topTransition: AnyTransition {
            .asymmetric(insertion: .move(edge: .top), removal: .identity)
        }

        init(quotesInfo: String, haveCurrencySwap: SwapViewModel, getCurrencySwap: SwapViewModel) {

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

                        withAnimation(.easeInOut(duration: 0.25)) {
                            self.isSwapCurrency.toggle()
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

    class SwapViewModel: ObservableObject {

        let icon: Image
        let title: String
        let currency: String
        let currencyType: String

        init(icon: Image, title: String, currency: String, currencyType: String) {

            self.icon = icon
            self.title = title
            self.currency  = currency
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

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)

            VStack(alignment: .leading, spacing: 4) {

                TopSwapView(viewModel: viewModel)

                HStack(spacing: 20) {

                    Divider()
                        .frame(width: 244, height: 1)
                        .background(Color.mainColorsGrayMedium)

                    SwapButtonView(viewModel: viewModel.swapButton)
                }

                BottomSwapView(viewModel: viewModel)
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

        }.frame(height: 160)
    }
}

extension CurrencySwapView {

    // MARK: - Swap

    struct SwapView: View {

        @ObservedObject var viewModel: ViewModel.SwapViewModel

        var body: some View {

            HStack(spacing: 16) {

                viewModel.icon
                    .resizable()
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 4) {

                    Text(viewModel.title)
                        .font(.textBodySR12160())
                        .foregroundColor(.mainColorsGray)

                    HStack(spacing: 4) {

                        Text(viewModel.currency)
                            .font(.textH4M16240())
                            .foregroundColor(.mainColorsBlack)

                        Text(viewModel.currencyType)
                            .font(.textH4M16240())
                            .foregroundColor(.mainColorsGrayMedium)
                    }
                }
            }
        }
    }

    // MARK: - Top

    struct TopSwapView: View {

        @ObservedObject var viewModel: ViewModel

        var body: some View {

            if viewModel.isSwapCurrency == true {

                CurrencySwapView.SwapView(viewModel: viewModel.haveCurrencySwap)
                    .transition(viewModel.bottomTransition)

            } else {

                CurrencySwapView.SwapView(viewModel: viewModel.getCurrencySwap)
                    .transition(viewModel.bottomTransition)
            }
        }
    }

    // MARK: - Bottom

    struct BottomSwapView: View {

        @ObservedObject var viewModel: ViewModel

        var body: some View {

            if viewModel.isSwapCurrency == true {

                CurrencySwapView.SwapView(viewModel: viewModel.getCurrencySwap)
                    .transition(viewModel.topTransition)

            } else {

                CurrencySwapView.SwapView(viewModel: viewModel.haveCurrencySwap)
                    .transition(viewModel.topTransition)
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
    }
}

struct CurrencySwapVIewComponent_Previews: PreviewProvider {
    static var previews: some View {

        VStack {

            CurrencySwapView(
                viewModel: .init(
                    quotesInfo: "1$ = 64.50 ₽",
                    haveCurrencySwap: .init(
                        icon: .init("Flag RUB"),
                        title: "У меня есть",
                        currency: "64.50",
                        currencyType: "RUB"),
                    getCurrencySwap: .init(
                        icon: .init("Flag USD"),
                        title: "Я получу",
                        currency: "1,00",
                        currencyType: "USD")))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
