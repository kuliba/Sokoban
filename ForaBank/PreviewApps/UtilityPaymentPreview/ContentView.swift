//
//  ContentView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import SwiftUI
import UIPrimitives

struct ContentView: View {
    
    @StateObject private var viewModel = PaymentsTransfersViewModel.default()
    
    var body: some View {
        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
