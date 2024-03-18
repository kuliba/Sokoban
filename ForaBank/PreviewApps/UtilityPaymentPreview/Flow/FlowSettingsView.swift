//
//  FlowSettingsView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 10.03.2024.
//

import SwiftUI

struct FlowSettingsView: View {
    
    @Binding var flow: Flow
    
    var body: some View {
        
        List {
            
            buttons()
            
            pickerSection("Load Last Payments", $flow.loadLastPayments)
            pickerSection("Load Operators", $flow.loadOperators)
        }
        .listStyle(.plain)
    }
}

private extension FlowSettingsView {
    
    func buttons() -> some View {
        
        HStack {
            
            Button("happy") {
                
                flow = .init(
                    loadLastPayments: .success,
                    loadOperators: .success
                )
            }
            .foregroundColor(.blue)
            
            Button("sad") {
                
                flow = .init(
                    loadLastPayments: .failure,
                    loadOperators: .failure
                )
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
        
        FlowSettingsView(flow: .constant(.happy))
    }
}
