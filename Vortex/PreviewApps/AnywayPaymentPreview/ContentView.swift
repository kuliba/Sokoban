//
//  ContentView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AmountComponent
import AnywayPaymentCore
import AnywayPaymentDomain
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
        let reducer = AnywayPaymentReducer()
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
            
            paymentView()
            infoOverlay()
        }
    }
    
    private func paymentView() -> some View {
        
        ComposedAnywayPaymentView(
            buttonTitle: buttonTitle,
            elements: viewModel.state.elements,
            isEnabled: isEnabled,
            event: viewModel.event,
            config: .preview,
            factory: .preview
        )
    }
    
    private func infoOverlay() -> some View {
        
        VStack(alignment: .leading) {
            
            Text(String(describing: viewModel.state.makeDigest()))
            Text("OTP: \(viewModel.state.infoOTP)")
        }
        .padding()
        .foregroundColor(.purple)
        .font(.caption)
        .background(Color.white.opacity(0.9))
        .padding(.bottom)
        .padding(.bottom)
    }
}

private extension AnywayPayment {
    
    var infoOTP: String {
        
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
