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
                
                Section(header: Text("Load PrePayment")) {
                    
                    Picker("Load PrePayment", selection: .constant("")) {
                        
                        ForEach(["Success", "Failure", "Error #"], id: \.self) {
                            
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .listStyle(.plain)
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
