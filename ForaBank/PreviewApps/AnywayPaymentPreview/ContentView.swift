//
//  ContentView.swift
//  AnywayPaymentPreview
//
//  Created by Igor Malyarov on 12.04.2024.
//

import AnywayPaymentCore
import RxViewModel
import SwiftUI

typealias ViewModel = RxViewModel<AnywayPayment, AnywayEvent, AnywayEffect>

struct ContentView: View {
    
    @StateObject private var viewModel: ViewModel = .init(
        initialState: .init(
            elements: [
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
            }
            
            infoOverlay()
        }
    }
    
    @ViewBuilder
    private func elementView(
        element: AnywayPayment.Element
    ) -> some View {
        
        switch element.uiComponentType {
        case let .field(field):
            Text(String(describing: field))
            
        case .otp:
            Text("TBD: OTP Field")
            
        case .productPicker:
            Text("TBD: Product Picker (Selector)")
        }
    }
    
    private func infoOverlay() -> some View {
        
        VStack {
            
            Text("OTP: \(viewModel.state.otp ?? "n/a")")
        }
    }
}

extension AnywayPayment.Element: Identifiable {
    
    public var id: ID {
        
        switch self {
        case let .field(field):
            return .fieldID(field.id)
            
        case let .parameter(parameter):
            return .fieldID(parameter.field.id)
            
        case let .widget(widget):
            return .widgetID(widget.id)
        }
    }
    
    public enum ID: Hashable {
        
        case fieldID(StringID)
        case widgetID(Widget.ID)
    }
}

private extension AnywayPayment {
    
    var otp: String? {
        
        guard let otp = elements.compactMap(\.otp).first
        else { return nil }
        
        return otp
    }
}

private extension AnywayPayment.Element {
    
    var otp: String? {
        
        guard case let .widget(.otp(otp)) = self
        else { return nil }
        
        return otp
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
