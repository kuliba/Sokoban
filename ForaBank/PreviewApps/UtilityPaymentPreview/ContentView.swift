//
//  ContentView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    @State private var flow: Flow = .happy
    
    var body: some View {
        
        VStack(spacing: 16) {
            
            PaymentsTransfersView(
                viewModel: .default(flow: flow)
            )
            .padding(.top)
            
            Divider()
            
            Text("Settings")
                .font(.headline.bold())
            
            List {
                
                pickerSection("Load PrePayment", $flow.loadPrePayment)
            }
            .listStyle(.plain)
        }
    }
    
    private func pickerSection<T: Hashable & CaseIterable & RawRepresentable>(
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

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            
            ContentView()
                .navigationTitle("Payments Transfers")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
