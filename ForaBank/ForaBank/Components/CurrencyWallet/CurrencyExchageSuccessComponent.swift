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
    
    class ViewModel: ObservableObject {
        
        let icon: Image
        let title: String
        let amount: String
        let delay: TimeInterval?

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
            
        internal init(icon: Image, title: String, amount: String, delay: TimeInterval?) {
            self.icon = icon
            self.title = title
            self.amount = amount
            self.delay = delay
        }
            
        init(state: State, amount: Double, currency: Currency,
             delay: TimeInterval?, model: Model ) {
                
            self.icon = state.appearance.icon
            self.title = state.appearance.text
            self.amount = model.amountFormatted(amount: amount,
                                                currencyCode: currency.description,
                                                style: .normal) ?? String(amount)
            self.delay = delay
        }

    }
}

//MARK: - View

struct CurrencyExchangeSuccessView: View {
    
    @ObservedObject var viewModel: ViewModel
    @State var isPresent = false

    var body: some View {
        
        VStack(spacing: 24) {
                
            viewModel.icon
                .resizable()
                .frame(width: 88, height: 88)
            
            if isPresent {
                
                Group {
                    
                    Text(viewModel.title)
                        .font(.textH3SB18240())
                        .foregroundColor(.textSecondary)
                
                    Text(viewModel.amount)
                        .font(.textH1SB24322())
                        .foregroundColor(.textSecondary)
                }
            }
            
        }.onAppear {
            if let delay = viewModel.delay {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation { isPresent = true }
                }
            } else {
                isPresent = true 
            }
        }
        
    }
}

//MARK: - Preview

struct CurrencyExchangeSuccessView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            CurrencyExchangeSuccessView(viewModel: .success)
                .previewLayout(.fixed(width: 375, height: 150))
            
            CurrencyExchangeSuccessView(viewModel: .error)
                .previewLayout(.fixed(width: 375, height: 300))
            
            CurrencyExchangeSuccessView(viewModel: .waiting)
                .previewLayout(.fixed(width: 375, height: 300))
        }
    }
}

extension CurrencyExchangeSuccessView.ViewModel {
    
    static var success = CurrencyExchangeSuccessView
                            .ViewModel(icon: Image("Done"),
                                       title: "Успешный перевод",
                                       amount: "100.23 $",
                                       delay: 2.0)
    
    static var error = CurrencyExchangeSuccessView
                            .ViewModel(icon: Image("Denied"),
                                       title: "Операция неуспешна!",
                                       amount: "80.23 $",
                                       delay: nil )
    
    static var waiting = CurrencyExchangeSuccessView
                            .ViewModel(icon: Image("waiting"),
                                       title: "Операция в обработке!",
                                       amount: "99.23 $",
                                       delay: nil)
    
    
}


