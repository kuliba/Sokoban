//
//  BankDefaultView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 18.01.2024.
//

import FastPaymentsSettings
import SwiftUI

struct BankDefaultView: View {
    
    let bankDefault: BankDefault
    let action: () -> Void
    
    var body: some View {
        
        HStack {
         
            icon()
            label()
            Spacer()
            bankDefaultIcon(bankDefault)
        }
    }
    
    #warning("replace with actual")
    private func icon() -> some View {
        
        Image(systemName: "building.columns")
            .imageScale(.large)
    }

    private func label() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Банк по умолчанию")
                .foregroundColor(.secondary)
                .font(.subheadline)
            
            Text("Фора-банк")
        }
    }
    
    @ViewBuilder
    private func bankDefaultIcon(
        _ bankDefault: BankDefault
    ) -> some View {
        
        switch bankDefault {
        case .onDisabled:
            ToggleMockView(status: .active)
                .opacity(0.4)
            
        case .offEnabled:
            VStack(alignment: .leading) {
                
                Button(action: action) {
            
                    ToggleMockView(status: .inactive)
                }
            }
            
        case .offDisabled:
            ToggleMockView(status: .inactive)
                .opacity(0.4)
        }
    }
}

extension BankDefaultView {
    
    typealias BankDefault = UserPaymentSettings.GetBankDefaultResponse.BankDefault
}

struct BankDefaultView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        List {
            
            bankDefaultView(.onDisabled)
            bankDefaultView(.offEnabled)
            bankDefaultView(.offDisabled)
        }
    }
    
    static func bankDefaultView(
        _ bankDefault: BankDefaultView.BankDefault
    ) -> some View {
        
        BankDefaultView(bankDefault: bankDefault, action: {})
    }
}
