//
//  ContentView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AmountComponent
import AnywayPaymentCore
import RxViewModel
import SwiftUI

typealias ViewModel = RxViewModel<AnywayPayment, AnywayPaymentEvent, AnywayPaymentEffect>

struct ContentView: View {
    
    @StateObject private var viewModel: ViewModel
    
#warning("mind `buttonTitle` and `isEnabled: true` - demo only, is a transaction level property")
    private let buttonTitle: String
    private let isEnabled: Bool
    
    init(
        buttonTitle: String = "Продолжить",
        isEnabled: Bool = true
    ) {
        let reducer = AnywayPaymentReducer(
            makeOTP: { Int($0.filter(\.isWholeNumber).prefix(6)) }
        )
        let viewModel = ViewModel(
            initialState: .preview,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
        
        self._viewModel = .init(wrappedValue: viewModel)
        self.buttonTitle = buttonTitle
        self.isEnabled = isEnabled
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            AnywayPaymentLayoutView(
                buttonTitle: buttonTitle,
                elements: viewModel.state.elements,
                isEnabled: isEnabled,
                event: viewModel.event,
                config: .preview
            )
            
            infoOverlay()
        }
    }
    
    private func infoOverlay() -> some View {
        
        VStack(alignment: .leading) {
            
            Text(String(describing: viewModel.state.digest))
            Text("OTP: \(viewModel.state.otp)")
        }
        .padding()
        .foregroundColor(.purple)
        .font(.caption)
        .background(Color.white.opacity(0.9))
        .padding(.bottom)
        .padding(.bottom)
    }
}

private extension AnywayPaymentLayoutView
where ElementView == AnywayPaymentElementView<AnywayPaymentElementFieldView, AnywayPaymentElementParameterView, AnywayPaymentElementWidgetView>,
      FooterView == AnywayPaymentFooterView {
    
    init(
        buttonTitle: String,
        elements: [AnywayPayment.Element],
        isEnabled: Bool,
        event: @escaping (AnywayPaymentEvent) -> Void,
        config: AnywayPaymentFooterConfig
    ) {
        self.init(
            elements: elements,
            elementView: {
                
                .init(state: $0, event: event)
            },
            footerView: {
                
                .init(
                    state: .init(
                        buttonTitle: buttonTitle,
                        elements: elements,
                        isEnabled: isEnabled
                    ),
                    event: { footerEvent in
                        
                        switch footerEvent {
                        case let .edit(decimal):
                            event(.widget(.amount(decimal)))
                            
                        case .continue:
                            event(.pay)
                        }
                    },
                    config: config
                )
            }
        )
    }
}

private extension AnywayPaymentElementView
where FieldView == AnywayPaymentElementFieldView,
      ParameterView == AnywayPaymentElementParameterView,
      WidgetView == AnywayPaymentElementWidgetView {
    
    init(
        state: AnywayPayment.Element,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) {
        self.init(
            state: state,
            event: event,
            factory: .init(
                fieldView: FieldView.init,
                parameterView: ParameterView.init,
                widgetView: WidgetView.init
            )
        )
    }
}

private extension AnywayPaymentFooter {
    
    init(
        buttonTitle: String,
        elements: [AnywayPayment.Element],
        isEnabled: Bool
    ) {
        self.init(
            buttonTitle: buttonTitle,
            core: elements.core,
            isEnabled: isEnabled
        )
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    var core: AnywayPaymentFooter.Core? {
        
        guard case let .widget(.core(core)) = self[id: .widgetID(.core)]
        else { return nil }
        
        return .init(value: core.amount, currency: core.currency.rawValue)
    }
}

private extension AnywayPayment {
    
    var otp: String {
        
        guard let widget = elements[id: .widgetID(.otp)],
              case let .widget(.otp(otp)) = widget
        else { return "n/a" }
        
        return otp.map { "\($0)" } ?? "<nil>"
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            ContentView()
                .navigationTitle("Anyway Payment")
        }
    }
}
