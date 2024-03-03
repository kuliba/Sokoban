//
//  ContentView.swift
//  UtilityPaymentPreview
//
//  Created by Igor Malyarov on 03.03.2024.
//

import RxViewModel
import SwiftUI
import UtilityPayment
import UIPrimitives

struct ContentView: View {
    
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
