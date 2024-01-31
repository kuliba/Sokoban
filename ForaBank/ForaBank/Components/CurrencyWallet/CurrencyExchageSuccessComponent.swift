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
        @Published var needRepeatButton: Bool = true

        var id: String { title }
        let icon: Image
        let title: String
        let subtitle: String?
        let amount: String
        let delay: TimeInterval?
        
        lazy var buttons: [ButtonIconTextView.ViewModel] = makeButtons()
        var repeatButton: ButtonSimpleView.ViewModel?
        
        private lazy var documentButton: ButtonIconTextView.ViewModel = makeDocumentButton()
        fileprivate lazy var detailsButton: ButtonIconTextView.ViewModel = makeDetailsButton()

        enum State {
                
            case success
            case error
            case wait
            case suspended
                
            var appearance: (icon: Image, text: String) {
                switch self {
                case .success: return (Image("Done"), "Успешный перевод")
                case .error: return (Image("Denied"), "Операция неуспешна!")
                case .suspended: return (Image("waiting"), "Операция временно приостановлена в целях безопасности!")
                case .wait: return (Image("waiting"), "Операция в обработке!")
                }
            }
            
            var subtitle: String? {
                switch self {
                case .suspended:
                    return Payments.Success.antifraudSubtitle
                    
                default:
                    return nil
                }
            }
        }
        
        internal init(icon: Image, title: String, subtitle: String?, state: State, amount: String, delay: TimeInterval? = 0) {
            
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
            self.state = state
            self.amount = amount
            self.delay = delay
        }
            
        init(
            state: State,
            amount: Double,
            currency: Currency,
            delay: TimeInterval? = 0,
            model: Model
        ) {
                
            self.icon = state.appearance.icon
            self.title = state.appearance.text
            self.subtitle = state.subtitle
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
            
            .init(icon: .init(image: .ic16File, background: .circle), title: .init(text: "Документ"), orientation: .vertical) { [weak self] in
                
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
        
        func makeRepeatButton() -> ButtonSimpleView.ViewModel {
            
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
                 
                    if viewModel.state == .suspended {
                        
                        Text(viewModel.title)
                            .font(.textH3Sb18240())
                            .foregroundColor(.systemColorError)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                    } else {
                        
                        Text(viewModel.title)
                            .font(.textH3Sb18240())
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                
                    if let subtitle = viewModel.subtitle {
                     
                        Text(subtitle)
                            .font(.textH3Sb18240())
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                
                    Text(viewModel.amount)
                        .font(.textH1Sb24322())
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
                    if viewModel.needRepeatButton {
                        if let repeatButton = viewModel.repeatButton {
                            ButtonSimpleView(viewModel: repeatButton)
                                .frame(height: 48)
                                .padding(.horizontal, 20)
                        }
                    } else if viewModel.state != .suspended {
                        HStack(alignment: .center, spacing: 36) {
                            ButtonIconTextView(viewModel: viewModel.detailsButton)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top)
                    }
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
                                       subtitle: nil,
                                       state: .success,
                                       amount: "100.23 $",
                                       delay: 2.0)
    
    static var error = CurrencyExchangeSuccessView
                            .ViewModel(icon: Image("Denied"),
                                       title: "Операция неуспешна!",
                                       subtitle: nil,
                                       state: .error,
                                       amount: "80.23 $",
                                       delay: nil )
    
    static var waiting = CurrencyExchangeSuccessView
                            .ViewModel(icon: Image("waiting"),
                                       title: "Операция в обработке!",
                                       subtitle: nil,
                                       state: .wait,
                                       amount: "99.23 $",
                                       delay: nil)
}
