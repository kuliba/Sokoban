//
//  CurrencyExchangeSuccessComponent.swift
//  ForaBank
//
//  Created by Dmitry Martynov on 17.07.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension CurrencyExchangeSuccessView {
    
    class ViewModel: ObservableObject, CurrencyWalletItem {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var isPresent = false
        @Published var state: State
        
        var id: String { title }
        let icon: Image
        let title: String
        let amount: String
        let delay: TimeInterval?
        
        lazy var buttons: [ButtonIconTextView.ViewModel] = makeButtons()
        lazy var simpleButton: ButtonSimpleView.ViewModel = makeSimpleButton()
        
        private lazy var documentButton: ButtonIconTextView.ViewModel = makeDocumentButton()
        private lazy var detailsButton: ButtonIconTextView.ViewModel = makeDetailsButton()

        enum State {
                
            case success
            case error
            case wait
                
            var appearance: (icon: Image, text: String) {
                switch self {
                case .success: return (Image("Done"), "Успешный перевод")
                case .error: return (Image("Denied"), "Операция неуспешна!")
                case .wait: return (Image("waiting"), "Операция в обработке!")
                }
            }
        }
            
        internal init(icon: Image, title: String, state: State, amount: String, delay: TimeInterval?) {
            
            self.icon = icon
            self.title = title
            self.state = state
            self.amount = amount
            self.delay = delay
        }
            
        init(state: State, amount: Double, currency: Currency,
             delay: TimeInterval?, model: Model ) {
                
            self.icon = state.appearance.icon
            self.title = state.appearance.text
            self.state = state
            self.amount = model.amountFormatted(amount: amount,
                                                currencyCode: currency.description,
                                                style: .normal) ?? String(amount)
            self.delay = delay
        }

        private func makeButtons() -> [ButtonIconTextView.ViewModel] {
            [documentButton, detailsButton]
        }
        
        private func makeDocumentButton() -> ButtonIconTextView.ViewModel {
            
            .init(icon: .init(image: .ic24CurrencyExchange, background: .circle), title: .init(text: "Документ"), orientation: .vertical) { [weak self] in
                
                guard let self = self else { return }
                self.action.send(CurrencyExchangeSuccessAction.Button.Document())
            }
        }
        
        private func makeDetailsButton() -> ButtonIconTextView.ViewModel {
            
            .init(icon: .init(image: .ic24Info, background: .circle), title: .init(text: "Детали"), orientation: .vertical) { [weak self] in
                
                guard let self = self else { return }
                self.action.send(CurrencyExchangeSuccessAction.Button.Details())
            }
        }
        
        private func makeSimpleButton() -> ButtonSimpleView.ViewModel {
            
            .init(title: "Повторить", style: .gray) {
                self.action.send(CurrencyExchangeSuccessAction.Button.Repeat())
            }
        }
    }
}

//MARK: - View

struct CurrencyExchangeSuccessView: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        VStack(spacing: 24) {
                
            viewModel.icon
                .resizable()
                .frame(width: 88, height: 88)
            
            if viewModel.isPresent {
                
                Group {
                    
                    Text(viewModel.title)
                        .font(.textH3SB18240())
                        .foregroundColor(.textSecondary)
                
                    Text(viewModel.amount)
                        .font(.textH1SB24322())
                        .foregroundColor(.textSecondary)
                }
                
                if viewModel.state == .success {
                    
                    HStack(alignment: .center, spacing: 36) {
                        
                        ForEach(viewModel.buttons) { viewModel in
                            ButtonIconTextView(viewModel: viewModel)
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.top)
                    
                } else {
                    
                    ButtonSimpleView(viewModel: viewModel.simpleButton)
                        .frame(height: 48)
                        .padding(.horizontal, 20)
                }
            }
            
        }.onAppear {
            if let delay = viewModel.delay {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation { viewModel.isPresent = true }
                }
            } else {
                viewModel.isPresent = true
            }
            
        }.padding(.vertical, 20)
    }
}

// MARK: - Actions

enum CurrencyExchangeSuccessAction {
    
    enum Button {
        
        struct Template: Action {}
        struct Document: Action {}
        struct Details: Action {}
        struct Repeat: Action {}
    }
}

//MARK: - Preview

struct CurrencyExchangeSuccessView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            CurrencyExchangeSuccessView(viewModel: .success)
            CurrencyExchangeSuccessView(viewModel: .error)
            CurrencyExchangeSuccessView(viewModel: .waiting)
        }
        .frame(width: 375)
        .previewLayout(.sizeThatFits)
    }
}

extension CurrencyExchangeSuccessView.ViewModel {
    
    static var success = CurrencyExchangeSuccessView
                            .ViewModel(icon: Image("Done"),
                                       title: "Успешный перевод",
                                       state: .success,
                                       amount: "100.23 $",
                                       delay: 2.0)
    
    static var error = CurrencyExchangeSuccessView
                            .ViewModel(icon: Image("Denied"),
                                       title: "Операция неуспешна!",
                                       state: .error,
                                       amount: "80.23 $",
                                       delay: nil )
    
    static var waiting = CurrencyExchangeSuccessView
                            .ViewModel(icon: Image("waiting"),
                                       title: "Операция в обработке!",
                                       state: .wait,
                                       amount: "99.23 $",
                                       delay: nil)
}
