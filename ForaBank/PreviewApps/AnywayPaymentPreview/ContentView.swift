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
    
    @StateObject private var viewModel: ViewModel = .init(
        initialState: .init(
            elements: [
                .field(.init(id: "1", title: "a", value: "bb")),
                .widget(.otp(""))
            ],
            infoMessage: nil,
            isFinalStep: false,
            isFraudSuspected: false,
            puref: "iFora || abc"
        ),
        reduce: AnywayPaymentReducer().reduce(_:_:),
        handleEffect: { _,_ in }
    )
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView {
                
                ForEach(viewModel.state.elements, content: elementView)
                    .padding(.horizontal)
            }
            
            infoOverlay()
        }
    }
    
    @ViewBuilder
    private func elementView(
        element: AnywayPayment.Element
    ) -> some View {
        
        ElementView(state: element, event: viewModel.event)
    }
    
    private func infoOverlay() -> some View {
        
        VStack {
            
            Text("OTP: \(viewModel.state.otp)")
        }
        .foregroundColor(.purple)
        .font(.caption)
    }
}

extension AnywayPayment.Element: Identifiable {
    
    public var id: ID {
        
        switch self {
        case let .field(field):
            return .fieldID(field.id)
            
        case let .parameter(parameter):
            return .parameterID(parameter.field.id)
            
        case let .widget(widget):
            return .widgetID(widget.id)
        }
    }
    
    public enum ID: Hashable {
        
        case fieldID(Field.ID)
        case parameterID(Parameter.Field.ID)
        case widgetID(Widget.ID)
    }
}

private extension AnywayPayment {
    
    var otp: String {
        
        guard let widget = elements[id: .widgetID(.otp)],
              case let .widget(.otp(otp)) = widget
        else { return "n/a" }
        
        return otp.isEmpty ? "<empty>" : otp
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
