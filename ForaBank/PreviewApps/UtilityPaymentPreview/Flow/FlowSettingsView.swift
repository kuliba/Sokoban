//
//  FlowSettingsView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 10.03.2024.
//

import SwiftUI

struct FlowSettingsView: View {
    
    @Binding var flowSettings: FlowSettings
    
    var body: some View {
        
        List {
            
            buttons()
            
            pickerSection("Load Prepayment Options", $flowSettings.loadOptions)
            pickerSection("Load Last Payments", $flowSettings.loadLastPayments)
            pickerSection("Load Operators", $flowSettings.loadOperators)
        }
        .listStyle(.plain)
    }
}

private extension FlowSettingsView {
    
    func buttons() -> some View {
        
        HStack {
            
            Button("happy") {
                
                flowSettings = .happy
            }
            .foregroundColor(.blue)
            
            Button("sad") {
                
                flowSettings = .sad
            }
            .foregroundColor(.red)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func pickerSection<T: Hashable & CaseIterable & RawRepresentable>(
        _ title: String,
        _ selection: Binding<T>
    ) -> some View where T.AllCases: RandomAccessCollection, T.RawValue == String {
        
        Section(header: Text(title)) {
            
            Picker(title, selection: selection) {
                
                ForEach(T.allCases, id: \.self) {
                    
                    Text($0.rawValue)
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct FlowSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        FlowSettingsView(flowSettings: .constant(.happy))
    }
}
