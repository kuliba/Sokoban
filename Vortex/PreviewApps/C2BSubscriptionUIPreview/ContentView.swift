//
//  ContentView.swift
//  C2BSubscriptionUIPreview
//
//  Created by Igor Malyarov on 11.02.2024.
//

import C2BSubscriptionUI
import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        C2BSubscriptionView_Demo(state: .control)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView()
    }
}
