//
//  PrePaymentMockView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI
import UtilityPayment

struct PrePaymentMockView: View {
    
    let event: (PrePaymentEvent) -> Void
    
    @State private var text = ""
    
    var body: some View {
        
        List {
            
            TextField("Enter Text", text: $text)
            
            Section(header: Text("Last Payments")) {
                
                ForEach(["failure", "error", "success"], id: \.self, content: lastPaymentView)
            }
            
            Section(header: Text("Operators")) {
                
                ForEach(["failure", "list", "single"], id: \.self, content: operatorView)
            }
            
            Section(header: Text("Footer")) {
                
                Button("Add Company") { event(.addCompany) }
                Button("Pay by Instruction") { event(.payByInstruction) }
                Button("Scan QR") { event(.scan) }
            }
        }
        .listStyle(.plain)
    }
    
    private func lastPaymentView(
        id: String
    ) -> some View {
        
        Button("Last Payment \"\(id)\"") { event(.select(.last(.init(id: id)))) }
    }
    
    private func operatorView(
        id: String
    ) -> some View {
        
        Button("Operator \"\(id)\"") { event(.select(.operator(.init(id: id)))) }
    }
}

struct PrePaymentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PrePaymentMockView(event: { _ in })
    }
}
