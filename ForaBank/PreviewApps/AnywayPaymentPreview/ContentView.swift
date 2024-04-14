//
//  ContentView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import RxViewModel
import SwiftUI

typealias ViewModel = RxViewModel<AnywayPayment, AnywayPaymentEvent, AnywayPaymentEffect>

struct ContentView: View {
    
    @StateObject private var viewModel: ViewModel
    
    init() {
        
        let reducer = AnywayPaymentReducer(
            makeOTP: { Int($0.filter(\.isWholeNumber).prefix(6)) }
        )
        let viewModel = ViewModel(
            initialState: .preview,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in }
        )
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            AnywayPaymentLayoutView(
                elements: viewModel.state.elements,
                event: viewModel.event
            )
            
            infoOverlay()
        }
    }
    
    private func infoOverlay() -> some View {
        
        VStack {
            
            Text("OTP: \(viewModel.state.otp)")
        }
        .foregroundColor(.purple)
        .font(.caption)
    }
}

private extension AnywayPaymentLayoutView where ElementView == AnywayPaymentElementView {
    
    init(
        elements: [AnywayPayment.Element],
        event: @escaping (AnywayPaymentEvent) -> Void
    ) {
        self.init(
            elements: elements,
            elementView: { .init(state: $0, event: event) }
        )
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
